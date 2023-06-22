FactoryBot.define do
  factory :workspace do
    sequence(:name) { |n| "#{Faker::Commerce.brand} #{n}" }
    # settings { '' }
    logo { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    sequence(:subdomain) { |n| "#{Faker::Internet.domain_word}#{n}" }
    # owner_id { create(:user).id }
    # created_by_id { create(:user).id }
    web_host { Faker::Internet.url }
    # coin_to_cash_rate { 0.01 }
    # order_reward_amount { 0 }
    # maximum_redeemed_coin_rate { 0.5 }
    # statement_address { '6623 & 6627, Jalan Mengkuang, Kampung Paya, 12200 Butterworth, Pulau Pinang.' }
    # invoice_size { 'A4' }
  end
end