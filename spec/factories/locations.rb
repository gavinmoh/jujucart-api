FactoryBot.define do
  factory :location do
    workspace
    sequence(:name) { |n| "#{Faker::Address.community} #{n}" }
    store
  end
end