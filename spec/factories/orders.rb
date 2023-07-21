FactoryBot.define do
  factory :order do
    transient { workspace { create(:workspace) } }
    customer_id { create(:customer, workspace: workspace).id }
    store_id { create(:store, workspace: workspace).id }
    subtotal { Faker::Number.within(range: 1..1000).to_s }
    billing_address_unit_number { Faker::Address.building_number }
    billing_address_street_address1 { Faker::Address.street_address }
    billing_address_street_address2 { Faker::Address.street_address }
    billing_address_postcode { Faker::Address.postcode }
    billing_address_city { Faker::Address.city }
    billing_address_state { Faker::Address.state }
    billing_address_country { Faker::Address.country }
    billing_address_latitude { Faker::Address.latitude }
    billing_address_longitude { Faker::Address.longitude }
    billing_address_contact_email { Faker::Internet.email }
    billing_address_contact_phone_number { Faker::PhoneNumber.cell_phone }
    billing_address_contact_name { Faker::Name.name }
    delivery_address_unit_number { Faker::Address.building_number }
    delivery_address_street_address1 { Faker::Address.street_address }
    delivery_address_street_address2 { Faker::Address.street_address }
    delivery_address_postcode { Faker::Address.postcode }
    delivery_address_city { Faker::Address.city }
    delivery_address_state { Faker::Address.state }
    delivery_address_country { Faker::Address.country }
    delivery_address_latitude { Faker::Address.latitude }
    delivery_address_longitude { Faker::Address.longitude }
    delivery_address_contact_email { Faker::Internet.email }
    delivery_address_contact_phone_number { Faker::PhoneNumber.cell_phone }
    delivery_address_contact_name { Faker::Name.name }
    order_type { 'delivery' }
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

    trait :guest_order do
      customer_id { nil }
    end
  end
end
