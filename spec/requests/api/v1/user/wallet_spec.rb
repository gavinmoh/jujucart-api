require 'swagger_helper'

RSpec.describe 'api/v1/user/wallets', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:wallet, workspace: user.current_workspace).id }

  path '/api/v1/user/wallets' do

    get('list wallets') do
      tags 'User Wallets'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      
      response(200, 'successful') do
        before do
          create_list(:wallet, 3, workspace: user.current_workspace)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/wallets/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show wallets') do
      response(200, 'successful') do
        tags 'User Wallets'
        produces 'application/json'
        security [ { bearerAuth: nil } ]
        
        run_test!
      end
    end    
  end
end