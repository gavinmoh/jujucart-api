FactoryBot.define do
  factory :product do
    transient { workspace { create(:workspace) } }
    name { "#{Faker::Lorem.word} #{SecureRandom.hex(6)}" }
    description { Faker::Lorem.paragraph }
    active { true }
    featured_photo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    category_id { create(:category, workspace: workspace).id }
    price { Faker::Number.within(range: 100..1000).to_s }
    discount_price { Faker::Number.within(range: 1..100).to_s }
    is_featured { [true, false].sample }
    tags { ['food', 'drink', 'snack'] }
    product_attributes { 
      [{ name: 'Colour', values: ['Red', 'Green', 'Blue'] }, 
       { name: 'Size', values: ['XL', 'L', 'M', 'S'] }]
    }

    after(:build) do |product, evaluator|
      product.workspace = evaluator.workspace if product.workspace.nil?
    end
  end
end