class PromotionBundleItem < ApplicationRecord
  belongs_to :promotion_bundle
  belongs_to :product

  validates :product_id, uniqueness: { scope: :promotion_bundle_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 1 }, allow_nil: false
end
