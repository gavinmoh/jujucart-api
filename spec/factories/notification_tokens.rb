FactoryBot.define do
  factory :notification_token do
    recipient_id { create(:user).id }
    token { SecureRandom.alphanumeric(32) }
  end
end