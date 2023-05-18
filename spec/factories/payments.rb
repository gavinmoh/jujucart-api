FactoryBot.define do
  factory :payment do
    order_id { create(:order).id }
    payment_type { 'cash' }
    transaction_reference { SecureRandom.hex(10) }
    amount { Faker::Number.within(range: 10..1000).to_s }
  end
end