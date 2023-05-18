FactoryBot.define do
  factory :notification do
    recipient_id { create(:user).id }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    record_id { create(:announcement).id }
    record_type { 'Announcement' }
    notification_type { ['Announcement'].sample }
  end
end