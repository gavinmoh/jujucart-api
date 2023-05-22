require 'swagger_helper'

RSpec.describe 'api/v1/user/sales_statements', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:sales_statement).id }

  path '/api/v1/user/sales_statements' do
    get('list sales statements') do
      tags 'User Sales Statements'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by,    in: :query, type: :string,  required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string,  required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      parameter name: :query,     in: :query, type: :string,  required: false, description: "Search by sales statement number"

      response(200, 'successful') do
        before do
          3.times do |n|
            month = (n + 1).months.ago
            create(:sales_statement, from_date: month.beginning_of_month, to_date: month.end_of_month)
          end
        end

        run_test!
      end

    end

  end

  path '/api/v1/user/sales_statements/{id}/pdf' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show sales statements pdf') do
      tags 'User Sales Statements'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      before do
        coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10)
        3.times do
          order = create(:order, :with_line_items, order_type: 'pos')
          create(:order_coupon, order: order, coupon: coupon)
          order.checkout!
          create(:payment, status: 'success', order: order, created_at: Faker::Time.between(from: Time.current.last_month.beginning_of_month, to: Time.current.last_month.end_of_month))
          order.complete!
        end
      end

      response(200, 'successful') do
        run_test!
      end
    end    
  end
end