class Api::V1::User::PaymentSerializer < ActiveModel::Serializer
  attributes :id, :status, :payment_type, :nanoid, :transaction_reference, 
             :order_id, :amount, :data
  attributes :created_at, :updated_at
  has_one :order
end
