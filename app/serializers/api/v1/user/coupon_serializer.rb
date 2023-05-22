class Api::V1::User::CouponSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :redemption_limit, :order_types, 
             :start_at, :end_at, :discount_by, :discount_price, 
             :discount_percentage, :minimum_spend, :maximum_cap, 
             :coupon_type, :discount_on
  attributes :created_at, :updated_at
  attribute  :total_redemptions, if: -> { @instance_options[:include_total_redemptions] }

  def total_redemptions
    object['total_redemptions'] || object.total_redemptions
  end
end
