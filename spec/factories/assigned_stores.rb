FactoryBot.define do
  factory :assigned_store do
    user_id { create(:user).id }
    store_id { create(:store).id }
  end
end