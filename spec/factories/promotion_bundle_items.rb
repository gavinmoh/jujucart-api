FactoryBot.define do
  factory :promotion_bundle_item do
    promotion_bundle_id { create(:promotion_bundle).id }
    product_id { create(:product).id }
    quantity { Faker::Number.within(range: 1..5) }
  end
end