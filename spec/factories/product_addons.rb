FactoryBot.define do
  factory :product_addon do
    transient do
      workspace { create(:workspace) }
      product { create(:product, workspace: workspace) }
    end
    product_id do
      case product.type
      when 'Product'
        product.id
      when 'ProductVariant'
        product.product_id
      end
    end
    sequence(:name) { |n| "#{Faker::Name.name}-#{n}" }
    price { Faker::Number.within(range: 100..1000).to_s }
    discount_price { Faker::Number.within(range: 100..1000).to_s }
    description { Faker::Lorem.paragraph }
    featured_photo { "data:image/png;base64,(#{Base64.encode64(File.read(File.join(Rails.root.join('spec/fixtures/product.png'))))})" }
  end
end
