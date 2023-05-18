FactoryBot.define do
  factory :store do
    name { "#{Faker::Lorem.word} #{SecureRandom.hex(6)}" }
    description { Faker::Lorem.paragraph }
    logo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    validate_inventory { false }
  end
end