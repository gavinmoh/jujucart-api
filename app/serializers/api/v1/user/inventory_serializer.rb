class Api::V1::User::InventorySerializer < ActiveModel::Serializer
  attributes :id, :product_id, :store_id, :nanoid
  attributes :created_at, :updated_at
  has_one :product
  has_one :store
  has_many :inventory_transactions
end
