FactoryBot.define do
  factory :promotion_bundle do
    name { Faker::Lorem.sentence }
    discount_by { PromotionBundle.discount_bies.keys.sample }
    discount_price { Faker::Number.within(range: 1..1000).to_s }
    discount_percentage { Faker::Number.within(range: 1..100) }
    start_at { Faker::Time.between(from: Time.zone.now - 15.days, to: Time.zone.now) }
    end_at { Faker::Time.between(from: Time.zone.now, to: Time.zone.now + 15.days) }
    active { true }
  end
end