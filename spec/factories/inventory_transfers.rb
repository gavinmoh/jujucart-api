FactoryBot.define do
  factory :inventory_transfer do
    transfer_from_location_id { create(:location).id }
    transfer_to_location_id { create(:location).id }
    remark { Faker::Lorem.sentence }
    acceptance_remark { Faker::Lorem.sentence }
    # accepted_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    # cancelled_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    # reverted_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    # accepted_by_id { create(:accepted_by).id }
    # cancelled_by_id { create(:cancelled_by).id }
    # reverted_by_id { create(:reverted_by).id }
    created_by_id { create(:user).id }

    trait :with_inventory_transfer_items do
      transient do
        inventory_transfer_items_count { 2 }
      end

      after(:create) do |inventory_transfer, evaluator|
        create_list(
          :inventory_transfer_item,
          evaluator.inventory_transfer_items_count,
          inventory_transfer: inventory_transfer
        )
      end
    end
  end
end