class Api::V1::User::InventorySerializer < ActiveModel::Serializer
  attributes :id, :product_id, :location_id, :nanoid, :quantity
  attributes :created_at, :updated_at
  has_one :product
  has_one :location
  has_many :inventory_transactions
end
