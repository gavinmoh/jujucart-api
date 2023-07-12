class Api::V1::Storefront::PaymentSerializer < ActiveModel::Serializer
  attributes :id, :status, :payment_type, :nanoid, :transaction_reference,
             :order_id, :amount, :payment_method
  attributes :created_at, :updated_at
  # has_one :order
end
