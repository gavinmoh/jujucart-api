class Api::V1::User::LineItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :name, :product_deleted, :product_data,
             :product_id, :order_id, :unit_price, :total_price
  attributes :created_at, :updated_at
  has_one :order
  has_one :product
end
