class Api::V1::User::InventoryTransactionSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :description, :order_id, :inventory_id
  attributes :created_at, :updated_at
  has_one :inventory
  has_one :order
end
