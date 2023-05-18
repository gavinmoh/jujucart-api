class Api::V1::User::WalletSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :current_amount
  attributes :created_at, :updated_at
  has_one :customer
end
