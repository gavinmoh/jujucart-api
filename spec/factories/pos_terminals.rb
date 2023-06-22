FactoryBot.define do
  factory :pos_terminal do
    workspace
    store_id { create(:store).id }
    terminal_id { Faker::Number.number(digits: 16) }
    label { Faker::Lorem.sentence }
  end
end