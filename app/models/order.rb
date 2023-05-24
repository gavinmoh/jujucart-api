class Order < ApplicationRecord
  include ActiveModel::Dirty, AASM

  belongs_to :customer, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :store

  has_one  :success_payment, -> { where(status: 'success') }, class_name: 'Payment'
  has_one  :order_coupon, dependent: :destroy
  has_one  :coupon, through: :order_coupon
  has_one  :valid_order_coupon, -> { code_valid.where(is_valid: true) }, class_name: 'OrderCoupon'
  has_many :line_items, -> { order(name: :asc) }, dependent: :destroy
  has_many :products, through: :line_items
  has_many :payments, dependent: :nullify
  has_many :inventory_transactions, dependent: :nullify

  has_paper_trail

  monetize :total_cents
  monetize :subtotal_cents
  monetize :delivery_fee_cents
  monetize :discount_cents
  monetize :redeemed_coin_value_cents

  scope :query, ->(keyword) { left_joins(:customer).where('orders.nanoid ILIKE :keyword OR accounts.name ILIKE :keyword', {keyword: "%#{keyword}%"}) }
  scope :paid, -> { where.not(status: ['pending', 'pending_payment', 'failed'])}

  reverse_geocoded_by :latitude, :longitude

  enum order_type: { pos: 'pos', delivery: 'delivery', pickup: 'pickup' }
  validates :order_type, presence: true

  before_validation :calculate_delivery_fee, if: -> { self.pending? && self.delivery? }
  before_validation :set_redeemed_coin_value, if: -> { self.pending? }
  before_validation :set_total, if: -> { self.pending? }
  before_validation :set_reward_amount, if: -> { self.pending? }
  
  aasm column: 'status', whiny_transitions: false, timestamps: true do
    state :pending, initial: true
    state :confirmed, :pending_payment, :packed, :shipped, 
          :completed, :cancelled, :failed, :voided, :refunded

    event :checkout do
      transitions from: :pending, to: :pending_payment, 
                  guard: [:customer_present?, :enough_stock?, :has_line_items?, :is_not_pos_order?],
                  after: [:create_inventory_transactions, :create_redeemed_coin_transaction]
    end

    event :pos_checkout do
      transitions from: :pending, to: :pending_payment,
                  guard: [:is_pos_order?, :enough_stock?],
                  after: [:create_inventory_transactions, :create_redeemed_coin_transaction]
    end

    event :confirm do
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
    self.subtotal = Money.new(self.line_items.sum('total_price_cents'))

    if recalculate_discount and self.order_coupon.present?
      self.order_coupon.calculate_discount(true)
    end      

    if self.valid_order_coupon.present?
      self.discount = self.valid_order_coupon.discount
    else
      self.discount = Money.new(0)
    end
    self.save!
  end

  def display_address
    [self.unit_number, self.street_address1, self.street_address2, self.postcode, self.city, self.state].reject(&:blank?).join(', ')
  end

  private
    def calculate_delivery_fee
      self.delivery_fee_cents = 0
    end

    def set_redeemed_coin_value
      unless self.customer.present? and (Setting.maximum_redeemed_coin_rate > 0) and (self.redeemed_coin > 0)
        self.redeemed_coin = 0
        self.redeemed_coin_value_cents = 0
        return
      end

      maximum_coin = self.subtotal_cents * Setting.maximum_redeemed_coin_rate
      self.redeemed_coin = [self.redeemed_coin, maximum_coin, self.customer.wallet.current_amount].min
      self.redeemed_coin_value = Money.from_amount(self.redeemed_coin * Setting.coin_to_cash_rate, "MYR")
    end

    def set_total
      self.total = self.subtotal + self.delivery_fee - self.discount - self.redeemed_coin_value
    end

    def set_reward_amount
      self.reward_coin = (self.subtotal_cents/100 * Setting.order_reward_amount) if Setting.order_reward_amount > 0
    end

    def create_inventory_transactions
      self.line_items.each do |line_item|
        inventory = line_item.product.inventories.find_or_create_by(location_id: self.store.location.id)
        inventory.inventory_transactions.create(
          order_id: self.id,
          quantity: -(line_item.quantity),
          description: "Order ##{self.nanoid} on purchased stock"
        )
      end
    end

    def create_return_inventory_transactions
      self.line_items.each do |line_item|
        next if line_item.product_deleted?
        inventory = line_item.product.inventories.find_or_create_by(location_id: self.store.location.id)
        inventory.inventory_transactions.create(
          order_id: self.id,
          quantity: (line_item.quantity),
          description: "Order ##{self.nanoid} on stock return"
        )
      end
    end

    def customer_present?
      unless self.customer_id.present?
        errors.add(:customer, 'is required')
        return false
      else
        return true
      end
    end

    def enough_stock?
      return true unless self.store.validate_inventory?
      order_line_items = self.line_items
      inventories = Inventory.joins(:location)
                             .where(location: { store_id: self.store_id })
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
      return has_enough_stock
    end

    def has_line_items?
      unless self.line_items.any?
        errors.add(:line_items, 'is required')
        return false
      else
        return true
      end
    end

    def is_not_pos_order?
      if self.pos?
        errors.add(:order_type, 'is POS')
        return false
      else
        return true
      end
    end

    def is_pos_order?
      unless self.pos?
        errors.add(:order_type, 'is not POS')
        return false
      else
        return true
      end
    end

    def has_success_payment?
      unless self.success_payment.present?
        errors.add(:payment, 'is not successful')
        return false
      else
        return true
      end
    end

    def coordinates_changed?
      (self.changed & ['latitude', 'longitude']).any?
    end

    def coordinates_complete?
      self.latitude.present? and self.longitude.present? 
    end

    def create_reward_transaction
      return unless self.reward_coin > 0
      return unless self.customer.present?
      transaction = self.customer.wallet.wallet_transactions.find_or_create_by(
        order_id: self.id,
        transaction_type: 'reward'
      )
      transaction.update(amount: self.reward_coin)
    end

    def create_redeemed_coin_transaction
      return unless self.redeemed_coin_value > 0
      return unless self.customer.present?
      transaction = self.customer.wallet.wallet_transactions.find_or_create_by(
        order_id: self.id,
        transaction_type: 'redeem'
      )
      transaction.update(amount: -(self.redeemed_coin))
    end

    def create_refund_coin_wallet_transaction
      return unless self.redeemed_coin_value > 0
      return unless self.customer.present?
      transaction = self.customer.wallet.wallet_transactions.find_or_create_by(
        order_id: self.id,
        transaction_type: 'refund'
      )
      transaction.update(amount: self.redeemed_coin)
    end

    def destroy_order_reward
      return unless self.reward_coin > 0
      return unless self.customer.present?
      transaction = self.customer.wallet.wallet_transactions.find_by(
        order_id: self.id,
        transaction_type: 'reward'
      )
      transaction.destroy if transaction.present?
    end

end
