FactoryBot.define do
  factory :wallet do
    transient { workspace { create(:workspace) } }
    customer_id { create(:customer, workspace: workspace).id }

    after(:build) do |wallet, evaluator|
      wallet.workspace = evaluator.workspace if wallet.workspace.nil?
    end
  end
end