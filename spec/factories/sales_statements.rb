FactoryBot.define do
  factory :sales_statement do
    from_date { Time.current.last_month.beginning_of_month }
    to_date { Time.current.last_month.end_of_month }
  end
end