class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true, class_name: 'BaseProduct'
  belongs_to :promotion_bundle, optional: true

  monetize :unit_price_cents
  monetize :total_price_cents
  monetize :discount_cents

  validates :quantity, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  before_save :assign_unit_price, if: -> { self.order.pending? }
  before_save :set_total_price, if: -> { self.order.pending? }
  before_save :set_name, if: -> { self.order.pending? }
  after_commit :update_order_price, if: -> { self.order.pending? }

  scope :joins_with_pending_orders, -> { joins(:order).where(orders: { status: 'pending' }) }
  scope :joins_with_parent_product, -> (parent_product_id) { joins(product: :product).where(product: {product_id: parent_product_id}) }

  private
    def assign_unit_price
      if self.product_id.nil?
        self.product_deleted = true
        self.unit_price_cents = 0
        return
      end
      self.unit_price = (product.discount_price_cents > 0) ? product.discount_price : product.price
    end

    def set_total_price
      self.total_price = self.unit_price * self.quantity
    end

    def set_name
      return if self.product_id.nil?
      case self.product.type
      when 'Product'
        self.name = self.product.name
      when 'ProductVariant'
        self.name = self.product.name || self.product.product.name
      end
    end

    def update_order_price
      return if self.order.destroyed?
      self.order.reload
      self.order.recalculate_price
    end
end
