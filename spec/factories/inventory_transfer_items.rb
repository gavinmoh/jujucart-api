FactoryBot.define do
  factory :inventory_transfer_item do
    inventory_transfer_id { create(:inventory_transfer).id }
    # name { Faker::Lorem.unique.word }
    product_id { create(:product).id }
    quantity { Faker::Number.within(range: 1..100) }
  end
end