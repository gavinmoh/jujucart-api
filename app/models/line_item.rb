class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true, class_name: 'BaseProduct'
  belongs_to :promotion_bundle, optional: true

  has_many :line_item_addons, dependent: :destroy

  accepts_nested_attributes_for :line_item_addons, allow_destroy: true

  monetize :unit_price_cents
  monetize :total_price_cents
  monetize :discount_cents

  validates :quantity, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  # for non-manual orders
  before_save :assign_unit_price, if: -> { order.pending? and !order.manual? }
  before_save :set_name_from_product, if: -> { order.pending? and !order.manual? }
  # common callbacks
  before_save :set_total_price, if: -> { order.pending? }
  # manual order to be able to add line items without product
  before_create :set_unit_price_from_product, if: -> { order.manual? and product_id.present? and unit_price_cents.zero? }
  before_create :set_name_from_product, if: -> { order.manual? and product_id.present? and name.blank? }

  after_commit :update_order_price, if: -> { order.pending? }

  scope :joins_with_pending_orders, -> { joins(:order).where(orders: { status: 'pending' }) }
  scope :joins_with_parent_product, ->(parent_product_id) { joins(product: :product).where(product: { product_id: parent_product_id }) }

  def product_unit_price
    product.discount_price_cents.positive? ? product.discount_price : product.price
  end

  def line_item_addons_price
    addons = LineItemAddon.where(line_item_id: id)
    if addons.any?
      addons.reject(&:product_addon_deleted?)
            .map(&:price)
            .sum(Money.new(0))
    else
      Money.new(0)
    end
  end

  def recalculate_price
    set_total_price
    save!
  end

  private

    def assign_unit_price
      if product_id.nil?
        self.product_deleted = true
        self.unit_price_cents = 0
        return
      end
      self.unit_price = product_unit_price
    end

    def set_unit_price_from_product
      self.unit_price = product_unit_price
    end

    def set_total_price
      self.total_price = (unit_price + line_item_addons_price) * quantity
    end

    def set_name_from_product
      return if product_id.nil?

      case product.type
      when 'Product'
        self.name = product.name
      when 'ProductVariant'
        self.name = product.name || product.product.name
      end
    end

    def update_order_price
      return if order.destroyed?

      order.reload
      order.recalculate_price
    end
end
