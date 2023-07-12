class Api::V1::Storefront::OrderSerializer < ActiveModel::Serializer
  attributes :id, :order_type, :nanoid, :customer_id, :status, :total,
             :subtotal, :delivery_fee, :discount, :store_id,
             :unit_number, :street_address1, :street_address2, :postcode, :city, :state, :latitude, :longitude,
             :courier_name, :tracking_number, :reward_coin, :pending_payment_at, :confirmed_at, :packed_at,
             :shipped_at, :completed_at, :cancelled_at, :failed_at, :created_by_id, :redeemed_coin, :redeemed_coin_value,
             :voided_at, :refunded_at
  attributes :created_at, :updated_at

  has_one :store
  has_one :order_coupon
  has_many :line_items
  has_one :success_payment
  has_many :payments
  has_many :order_attachments
end
