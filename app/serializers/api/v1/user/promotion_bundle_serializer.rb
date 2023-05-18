class Api::V1::User::PromotionBundleSerializer < ActiveModel::Serializer
  attributes :id, :name, :discount_by, :discount_price, :discount_percentage, :start_at, :end_at, :active
  attributes :created_at, :updated_at
  has_many :promotion_bundle_items
end
