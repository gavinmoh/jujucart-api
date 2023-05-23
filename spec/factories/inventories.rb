FactoryBot.define do
  factory :inventory do
    product_id { create(:product).id }
    location_id { create(:store).location.id }
  end
end