require 'swagger_helper'

RSpec.describe 'api/v1/user/payments', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:payment).id }

  path '/api/v1/user/payments' do
    get('list payments') do
      tags 'User Payments'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :order_id, in: :query, type: :string, required: false, description: 'Order ID'
      parameter name: :payment_type, in: :query, type: :string, required: false, description: 'Payment Type'
      parameter name: :filter_date_by, in: :query, type: :string, required: false, description: 'Filter Date By'
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'From Date'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'To Date'

      response(200, 'successful') do
        before do
          create_list(:payment, 3)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/payments/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show payments') do
      tags 'User Payments'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end    
  end
end