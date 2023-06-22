FactoryBot.define do
  factory :promotion_bundle_item do
    transient { workspace { create(:workspace) } }
    promotion_bundle_id { create(:promotion_bundle, workspace: workspace).id }
    product_id { create(:product, workspace: workspace).id }
    quantity { Faker::Number.within(range: 1..5) }
  end
end