FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "#{Faker::Address.community} #{n}" }
    store
  end
end