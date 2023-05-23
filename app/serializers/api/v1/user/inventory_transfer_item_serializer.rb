class Api::V1::User::InventoryTransferItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :inventory_transfer_id, :product_id
  attributes :created_at, :updated_at
  has_one :inventory_transfer
  has_one :product
end
