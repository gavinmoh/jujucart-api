FactoryBot.define do
  factory :order_coupon do
    transient { workspace { create(:workspace) } }
    order_id { create(:order, workspace: workspace).id }
    coupon_id { create(:coupon, workspace: workspace).id }

    after(:build) do |order_coupon|
      order_coupon.code = order_coupon.coupon.code if order_coupon.coupon && order_coupon.code.blank?
    end
  end
end