FactoryBot.define do
  factory :wallet do
    workspace
    customer_id { create(:customer, workspace: workspace).id }
  end
end