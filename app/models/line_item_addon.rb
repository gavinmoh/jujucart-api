class LineItemAddon < ApplicationRecord
  belongs_to :line_item, touch: true
  belongs_to :product_addon

  monetize :price_cents

  validates :product_addon_id, uniqueness: { scope: :line_item_id }, on: :create
  validate :product_addon_must_belongs_to_line_item_product, on: :create

  before_validation :set_name_and_price

  after_commit :update_line_item_price

  def product_addon_price
    product_addon.discount_price_cents.positive? ? product_addon.discount_price : product_addon.price
  end

  private

    def set_name_and_price
      return if product_addon.blank?
      return if product_addon_deleted?
      return if line_item.blank?
      return unless line_item.order.pending?

      self.product_addon_name = product_addon.name
      self.price = product_addon_price
    end

    def product_addon_must_belongs_to_line_item_product
      return if product_addon.blank?
      return if line_item.blank?

      case line_item.product.type
      when 'Product'
        return if product_addon.product_id == line_item.product_id
      when 'ProductVariant'
        return if product_addon.product_id == line_item.product.product_id
      end

      errors.add(:product_addon_id, :invalid)
    end

    def update_line_item_price
      line_item.recalculate_price
    end
end
