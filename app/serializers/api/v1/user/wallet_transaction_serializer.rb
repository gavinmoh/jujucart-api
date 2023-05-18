class Api::V1::User::WalletTransactionSerializer < ActiveModel::Serializer
  attributes :id, :wallet_id, :transaction_type, :amount, :order_id
  attributes :created_at, :updated_at
  has_one :wallet
  has_one :order
end
