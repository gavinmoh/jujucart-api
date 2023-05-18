FactoryBot.define do
  factory :session do
    account_id { create(:account).id }
    expired_at { Time.current + 1.day }
  end
end