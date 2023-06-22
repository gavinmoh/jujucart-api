FactoryBot.define do
  factory :line_item do
    transient { workspace { create(:workspace) } }
    order_id { create(:order, workspace: workspace).id }
    product_id { create(:product, workspace: workspace).id }
    quantity { Faker::Number.within(range: 1..20) }
    name { Faker::Lorem.word }
    product_deleted { false }
    
    after(:build) do |line_item|
      line_item.name = line_item.product.name
      line_item.unit_price = line_item.product.discount_price_cents > 0 ? line_item.product.discount_price : line_item.product.price
    end
  end
end