FactoryBot.define do
  factory :callback_log do
    request_headers { '' }
    request_body { '' }
    callback_from { '' }
    processed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
  end
end