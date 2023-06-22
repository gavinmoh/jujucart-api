FactoryBot.define do
  factory :sales_statement do
    transient { workspace { create(:workspace) } }
    from_date { Time.current.last_month.beginning_of_month }
    to_date { Time.current.last_month.end_of_month }

    after(:build) do |sales_statement, evaluator|
      sales_statement.workspace = evaluator.workspace if sales_statement.workspace.nil?
    end
  end
end