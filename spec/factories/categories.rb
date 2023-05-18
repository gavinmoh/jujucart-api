FactoryBot.define do
  factory :category do
    name { "#{Faker::Lorem.word} #{SecureRandom.hex(6)}" }
    sequence(:display_order) { |n| n }
    photo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
  end
end