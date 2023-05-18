FactoryBot.define do
  factory :wallet do
    customer_id { create(:customer).id }
  end
end