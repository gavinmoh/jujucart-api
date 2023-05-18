FactoryBot.define do
  factory :inventory do
    product_id { create(:product).id }
    store_id { create(:store).id }
  end
end