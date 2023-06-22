FactoryBot.define do
  factory :location do
    transient { workspace { create(:workspace) } }
    transient { store { create(:store, workspace: workspace) } }
    sequence(:name) { |n| "#{Faker::Address.community} #{n}" }
    
    after(:build) do |location, evaluator|
      location.workspace = evaluator.workspace if location.workspace.nil?
      location.store = evaluator.store if location.store.nil?
    end
  end
end