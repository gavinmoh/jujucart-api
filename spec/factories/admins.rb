FactoryBot.define do
  factory :admin do
    sequence(:name) { |n| "#{n}-#{Faker::Name.name}" }
    sequence(:email) { |n| "#{n}-#{Faker::Internet.unique.safe_email}" }
    phone_number { Faker::PhoneNumber.phone_number }
    password { Faker::Internet.password }
    type { 'Admin' }
    active { true }
    profile_photo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
  end
end