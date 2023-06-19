FactoryBot.define do
  factory :pos_terminal do
    store_id { create(:store).id }
    terminal_id { Faker::Number.number(digits: 16) }
    label { Faker::Lorem.sentence }
  end
end