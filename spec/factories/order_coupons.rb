FactoryBot.define do
  factory :order_coupon do
    order_id { create(:order).id }
    coupon_id { create(:coupon).id }

    after(:build) do |order_coupon|
      order_coupon.code = order_coupon.coupon.code if order_coupon.coupon && order_coupon.code.blank?
    end
  end
end