FactoryBot.define do
  factory :line_item_addon do
    transient do
      line_item { create(:line_item) }
    end
    line_item_id { line_item.id }
    product_addon_id do
      case line_item.product.type
      when 'Product'
        create(:product_addon, product: line_item.product).id
      when 'ProductVariant'
        create(:product_addon, product: line_item.product.product).id
      end
    end
    # price { Faker::Number.within(range: 1..1000).to_s }
    # product_addon_name { Faker::Lorem.unique.word }
    # product_addon_deleted { '' }
  end
end
