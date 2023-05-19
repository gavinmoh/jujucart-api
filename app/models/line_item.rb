class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  belongs_to :promotion_bundle, optional: true

  monetize :unit_price_cents
  monetize :total_price_cents
  monetize :discount_cents

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  validate :cannot_add_product_variant_when_product_has_no_variant

  before_save  :assign_unit_price, :set_total_price
  after_commit :update_order_price

  private
    def assign_unit_price
      return if self.product_deleted
      return if self.quantity <= 0
      
      if self.product_id.nil?
        self.assign_attributes(product_deleted: true)
        return
      end

      if product.discount_price_cents > 0
        self.assign_attributes(
          name: self.product.name,
          unit_price: product.discount_price
        )
      else
        self.assign_attributes(
          name: self.product.name,
          unit_price: product.price
        )
      end
    end

    def set_total_price
      self.total_price = self.unit_price * self.quantity
    end

    def update_order_price
      return if self.order.destroyed?
      self.order.reload
      self.order.recalculate_price
    end

    def cannot_add_product_variant_when_product_has_no_variant
      return if self.product_id.nil?
      return unless self.product.type == 'ProductVariant'
      errors.add(:product, "has variants") if self.product.product.has_no_variant
    end
end
