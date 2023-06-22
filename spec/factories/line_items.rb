FactoryBot.define do
  factory :line_item do
    transient { workspace { create(:workspace) } }
    order_id { create(:order, workspace: workspace).id }
    product_id { create(:product, workspace: workspace).id }
    quantity { Faker::Number.within(range: 1..20) }
    # name { Faker::Lorem.word }
    # product_deleted { false }
    
    # after(:build) do |line_item|
    #   if line_item.product.present?
    #     line_item.name = line_item.product.name
    #     line_item.unit_price = line_item.product.discount_price_cents > 0 ? line_item.product.discount_price : line_item.product.price
    #   else
    #     line_item.name = Faker::Lorem.word
    #     line_item.unit_price = Faker::Number.within(range: 1..1000).to_s
    #   end
    # end
  end
end