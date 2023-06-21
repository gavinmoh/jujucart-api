FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "#{n}-#{Faker::Name.name}" }
    sequence(:email) { |n| "#{n}-#{Faker::Internet.unique.safe_email}" }
    phone_number { Faker::PhoneNumber.phone_number }
    password { Faker::Internet.password }
    type { 'User' }
    active { true }
    profile_photo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    role { 'admin' }

    trait :user_admin do
      role { 'admin' }
    end

    trait :cashier do
      role { 'cashier' }
    end

    after(:create) do |user|
      create(:user_workspace, user: user)
    end
  end
end