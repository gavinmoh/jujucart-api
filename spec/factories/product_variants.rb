FactoryBot.define do
  factory :product_variant do
    transient { workspace { create(:workspace) } }
    product_id { create(:product, workspace: workspace).id }
    sequence(:name) { |n| "#{Faker::Name.name}-#{n}" }
    price { Faker::Number.within(range: 100..1000).to_s }
    discount_price { Faker::Number.within(range: 100..1000).to_s }
    description { Faker::Lorem.paragraph }
    featured_photo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    product_attributes { 
      [{ name: 'Colour', value: ['Red', 'Green', 'Blue'].sample }, 
       { name: 'Size', value: ['XL', 'L', 'M', 'S'].sample }]
    }
  end
end