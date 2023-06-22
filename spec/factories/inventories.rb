FactoryBot.define do
  factory :inventory do
    transient { workspace { create(:workspace) } }
    product_id { create(:product).id }
    location_id { create(:store, workspace: workspace).location.id }

    after(:build) do |inventory, evaluator|
      inventory.workspace = evaluator.workspace if inventory.workspace.nil?
    end
  end
end