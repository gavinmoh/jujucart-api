class Api::V1::User::OrderCouponSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :coupon_id, :discount, :code, :error_code, :is_valid
  attributes :created_at, :updated_at

  has_one :order
  has_one :coupon
end
