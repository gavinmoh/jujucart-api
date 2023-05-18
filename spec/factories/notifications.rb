FactoryBot.define do
  factory :notification do
    recipient_id { create(:user).id }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    record_id { create(:order).id }
    record_type { 'Order' }
    notification_type { ['Order'].sample }
  end
end