class Order < ApplicationRecord
  include AASM
  include ActiveModel::Dirty

  belongs_to :workspace
  belongs_to :customer, optional: true
  belongs_to :created_by, class_name: 'Account', optional: true
  belongs_to :store

  has_one  :success_payment, -> { where(status: 'success') }, class_name: 'Payment', dependent: :nullify
  has_one  :pending_billplz_payment, -> { where(status: 'pending').where('data->>\'service_provider\' = ?', 'Billplz') }, class_name: 'Payment', dependent: :nullify
  has_one  :pending_stripe_payment, -> { where(status: 'pending').where('data->>\'service_provider\' = ?', 'Stripe') }, class_name: 'Payment', dependent: :nullify
  has_one  :order_coupon, dependent: :destroy
  has_one  :coupon, through: :order_coupon
  has_one  :valid_order_coupon, -> { code_valid.where(is_valid: true) }, class_name: 'OrderCoupon', dependent: :destroy
  has_many :line_items, -> { order(name: :asc) }, dependent: :destroy
  has_many :products, through: :line_items
  has_many :payments, dependent: :nullify
  has_many :inventory_transactions, dependent: :nullify
  has_many :order_attachments, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :order_attachments, allow_destroy: true, reject_if: proc { |attributes| attributes['file'].blank? }

  has_paper_trail

  monetize :total_cents
  monetize :subtotal_cents
  monetize :delivery_fee_cents
  monetize :discount_cents
  monetize :redeemed_coin_value_cents

  scope :query, ->(keyword) { left_joins(:customer).where('orders.nanoid ILIKE :keyword OR accounts.name ILIKE :keyword', { keyword: "%#{keyword}%" }) }
  scope :paid, -> { where.not(status: %w[pending pending_payment failed]) }
  scope :include_pending_manual_order, -> { where("(status != 'pending' AND order_type != 'manual') OR order_type = 'manual'") }

  reverse_geocoded_by :latitude, :longitude

  enum order_type: { pos: 'pos', delivery: 'delivery', pickup: 'pickup', manual: 'manual' }
  validates :order_type, presence: true

  before_validation :calculate_delivery_fee, if: -> { pending? && delivery? }
  before_validation :set_redeemed_coin_value, if: -> { pending? }
  before_validation :set_total, if: -> { pending? }
  before_validation :set_reward_amount, if: -> { pending? }

  aasm column: 'status', whiny_transitions: false, timestamps: true do
    state :pending, initial: true
    state :confirmed, :pending_payment, :packed, :shipped,
          :completed, :cancelled, :failed, :voided, :refunded

    event :checkout do
      transitions from: :pending, to: :pending_payment,
                  guard: [:enough_stock?, :has_line_items?, :is_not_pos_order?],
                  after: [:create_inventory_transactions, :create_redeemed_coin_transaction]
    end

    event :pos_checkout do
      transitions from: :pending, to: :pending_payment,
                  guard: [:is_pos_order?, :enough_stock?],
                  after: [:create_inventory_transactions, :create_redeemed_coin_transaction]
    end

    event :confirm do
      transitions from: :pending, to: :confirmed, guard: [:is_manual_order?, :has_line_items?],
                  after: [:create_inventory_transactions, :create_redeemed_coin_transaction]
      transitions from: :pending_payment, to: :confirmed, guard: [:has_success_payment?]
    end

    event :cancel do
      transitions from: :confirmed, to: :cancelled,
                  after: [:create_return_inventory_transactions,
                          :create_refund_coin_wallet_transaction]
    end

    event :fail do
      transitions from: :pending_payment, to: :failed,
                  after: [:create_return_inventory_transactions,
                          :create_refund_coin_wallet_transaction]
    end

    event :pack do
      transitions from: :confirmed, to: :packed
    end

    event :ship do
      transitions from: :packed, to: :shipped
    end

    event :complete do
      transitions from: [:pending_payment, :confirmed], to: :completed,
                  guard: [:is_pos_order?, :has_success_payment?],
                  after: [:create_reward_transaction]
      transitions from: [:confirmed], to: :completed,
                  guard: [:is_manual_order?],
                  after: [:create_reward_transaction]
      transitions from: [:packed, :shipped], to: :completed,
                  after: [:create_reward_transaction]
    end

    event :void do
      transitions from: :completed, to: :voided,
                  guard: [:is_pos_order?],
                  after: [:create_refund_coin_wallet_transaction, :create_return_inventory_transactions, :destroy_order_reward]
    end

    event :refund do
      transitions from: :completed, to: :refunded, guard: [:is_pos_order?],
                  after: [:create_refund_coin_wallet_transaction, :create_return_inventory_transactions, :destroy_order_reward]
    end
  end

  def recalculate_price(recalculate_discount = true)
    self.subtotal = Money.new(line_items.sum('total_price_cents'))

    order_coupon.calculate_discount(true) if recalculate_discount and order_coupon.present?

    self.discount = if valid_order_coupon.present?
                      valid_order_coupon.discount
                    else
                      Money.new(0)
                    end
    save!
  end

  def display_delivery_address
    [
      delivery_address_unit_number,
      delivery_address_street_address1,
      delivery_address_street_address2,
      delivery_address_postcode,
      delivery_address_city,
      delivery_address_state
    ].compact_blank.join(', ')
  end

  private

    def calculate_delivery_fee
      self.delivery_fee_cents = 0
    end

    def set_redeemed_coin_value
      unless customer.present? and ((workspace&.maximum_redeemed_coin_rate || 0) > 0) and (redeemed_coin > 0)
        self.redeemed_coin = 0
        self.redeemed_coin_value_cents = 0
        return
      end

      maximum_coin = subtotal_cents * workspace&.maximum_redeemed_coin_rate
      self.redeemed_coin = [redeemed_coin, maximum_coin, customer.wallet.current_amount].min
      self.redeemed_coin_value = Money.from_amount(redeemed_coin * workspace&.coin_to_cash_rate, "MYR")
    end

    def set_total
      self.total = subtotal + delivery_fee - discount - redeemed_coin_value
    end

    def set_reward_amount
      self.reward_coin = (subtotal_cents / 100 * (workspace&.order_reward_amount || 0)) if (workspace&.order_reward_amount || 0) > 0
    end

    def create_inventory_transactions
      line_items.includes(:product).find_each do |line_item|
        next if line_item.product_id.nil?

        inventory = line_item.product.inventories.find_or_create_by(location_id: store.location.id, workspace_id: workspace_id)
        inventory.inventory_transactions.create(
          order_id: id,
          quantity: -line_item.quantity,
          description: "Order ##{nanoid} on purchased stock"
        )
      end
    end

    def create_return_inventory_transactions
      line_items.includes(:product).find_each do |line_item|
        next if line_item.product_id.nil?

        inventory = line_item.product.inventories.find_or_create_by(location_id: store.location.id, workspace_id: workspace_id)
        inventory.inventory_transactions.create(
          order_id: id,
          quantity: line_item.quantity,
          description: "Order ##{nanoid} on stock return"
        )
      end
    end

    def enough_stock?
      return true unless store.validate_inventory?

      order_line_items = line_items
      inventories = Inventory.joins(:location)
                             .where(location: { store_id: store_id })
                             .where(product_id: order_line_items.map(&:product_id))
      has_enough_stock = true
      order_line_items.find_each do |line_item|
        if line_item.product_id.nil?
          errors.add(:line_items, "#{line_item.name} is currently not available")
          has_enough_stock = false
          next
        end

        inventory_quantity = inventories.find { |inventory| inventory.product_id == line_item.product_id }&.quantity || 0
        if line_item.quantity > inventory_quantity
          errors.add(:line_items, "#{line_item.name} has insufficient stock")
          has_enough_stock = false
        end
      end
      has_enough_stock
    end

    def has_line_items?
      if line_items.any?
        true
      else
        errors.add(:line_items, 'is required')
        false
      end
    end

    def is_not_pos_order?
      if pos?
        errors.add(:order_type, 'is POS')
        false
      else
        true
      end
    end

    def is_pos_order?
      if pos?
        true
      else
        errors.add(:order_type, 'is not POS')
        false
      end
    end

    def is_manual_order?
      if manual?
        true
      else
        errors.add(:order_type, 'is not manual')
        false
      end
    end

    def has_success_payment?
      if success_payment.present?
        true
      else
        errors.add(:payment, 'is not successful')
        false
      end
    end

    def coordinates_changed?
      (changed & %w[delivery_address_latitude delivery_address_longitude]).any?
    end

    def coordinates_complete?
      delivery_address_latitude.present? and delivery_address_longitude.present?
    end

    def create_reward_transaction
      return unless reward_coin.positive?
      return if customer.blank?

      transaction = customer.wallet.wallet_transactions.find_or_create_by(
        order_id: id,
        transaction_type: 'reward'
      )
      transaction.update(amount: reward_coin)
    end

    def create_redeemed_coin_transaction
      return unless redeemed_coin_value.positive?
      return if customer.blank?

      transaction = customer.wallet.wallet_transactions.find_or_create_by(
        order_id: id,
        transaction_type: 'redeem'
      )
      transaction.update(amount: -redeemed_coin)
    end

    def create_refund_coin_wallet_transaction
      return unless redeemed_coin_value.positive?
      return if customer.blank?

      transaction = customer.wallet.wallet_transactions.find_or_create_by(
        order_id: id,
        transaction_type: 'refund'
      )
      transaction.update(amount: redeemed_coin)
    end

    def destroy_order_reward
      return unless reward_coin.positive?
      return if customer.blank?

      transaction = customer.wallet.wallet_transactions.find_by(
        order_id: id,
        transaction_type: 'reward'
      )
      transaction.destroy if transaction.present?
    end
end
