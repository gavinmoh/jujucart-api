class Api::V1::Storefront::LineItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :name, :product_deleted, :product_data,
             :product_id, :order_id, :unit_price, :total_price, :discount,
             :promotion_bundle_id
  attributes :created_at, :updated_at
  # has_one :order
  has_one :product
  # has_one :promotion_bundle
end
