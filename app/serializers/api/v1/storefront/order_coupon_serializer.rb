class Api::V1::Storefront::OrderCouponSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :coupon_id, :discount, :code, :error_code, :is_valid
  attributes :created_at, :updated_at
end
