class Api::V1::User::PromotionBundleItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :promotion_bundle_id, :product_id
  attributes :created_at, :updated_at
  has_one :promotion_bundle
  has_one :product
end
