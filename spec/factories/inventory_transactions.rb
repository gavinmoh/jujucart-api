FactoryBot.define do
  factory :inventory_transaction do
    inventory_id { create(:inventory).id }
    quantity { Faker::Number.within(range: 1..1000) }
    description { Faker::Lorem.paragraph }
  end
end