FactoryBot.define do
  factory :order do
    transient { workspace { create(:workspace) } }
    customer_id { create(:customer, workspace: workspace).id }
    store_id { create(:store, workspace: workspace).id }
    unit_number { Faker::Address.building_number }
    subtotal { Faker::Number.within(range: 1..1000).to_s }
    street_address1 { Faker::Address.street_address }
    street_address2 { Faker::Address.street_address }
    postcode { Faker::Address.postcode }
    city { Faker::Address.city }
    state { Faker::Address.state }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    order_type { Order.order_types.keys.sample }
    courier_name { ['POS Laju', 'DHL', 'J&T Express'].sample }
    tracking_number { Faker::Number.number(digits: 10) }

    after(:build) do |order, evaluator|
      order.workspace = evaluator.workspace if order.workspace.nil?
    end

    trait :with_line_items do
      after(:create) do |order|
        3.times do
          create(:line_item, order: order, product: create(:product, workspace: order.workspace))
        end
      end
    end
  end
end