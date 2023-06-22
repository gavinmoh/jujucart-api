FactoryBot.define do
  factory :coupon do
    workspace
    name { Faker::Lorem.unique.word }
    code { SecureRandom.alphanumeric(8) }
    redemption_limit { Faker::Number.within(range: 50..1000) }
    order_types { [Order.order_types.keys.sample] }
    start_at { Faker::Time.between(from: Time.zone.now - 15.days, to: Time.zone.now) }
    end_at { Faker::Time.between(from: Time.zone.now, to: Time.zone.now + 15.days) }
    discount_by { Coupon.discount_bies.keys.sample }
    discount_price { Faker::Number.within(range: 1..1000).to_s }
    discount_percentage { Faker::Number.within(range: 1..100) }
    minimum_spend { Faker::Number.within(range: 10..100).to_s }
    # maximum_cap { '' }
    coupon_type { Coupon.coupon_types.keys.sample }
    discount_on { Coupon.discount_ons.keys.sample }
  end
end