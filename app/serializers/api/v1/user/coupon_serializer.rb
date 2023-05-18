class Api::V1::User::CouponSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :redemption_limit, :order_types, 
             :start_at, :end_at, :discount_by, :discount_price, 
             :discount_percentage, :minimum_spend, :maximum_cap, 
             :coupon_type, :discount_on
  attributes :created_at, :updated_at
end
