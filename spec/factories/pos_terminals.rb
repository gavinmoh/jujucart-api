FactoryBot.define do
  factory :pos_terminal do
    transient { workspace { create(:workspace) } }
    store_id { create(:store, workspace: workspace).id }
    terminal_id { Faker::Number.number(digits: 16) }
    label { Faker::Lorem.sentence }

    after(:build) do |pos_terminal, evaluator|
      pos_terminal.workspace = evaluator.workspace if pos_terminal.workspace.nil?
    end
  end
end