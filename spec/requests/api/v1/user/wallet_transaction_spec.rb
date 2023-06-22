require 'swagger_helper'

RSpec.describe 'api/v1/user/wallet_transactions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:wallet_id) { create(:wallet, workspace: user.current_workspace).id }
  let(:id) { create(:wallet_transaction, wallet_id: wallet_id).id }

  path '/api/v1/user/wallets/{wallet_id}/wallet_transactions' do
    parameter name: 'wallet_id', in: :path, type: :string, description: 'wallet_id'

    get('list wallet transactions') do
      tags 'User Wallet Transactions'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      
      response(200, 'successful') do
        before do
          create_list(:wallet_transaction, 3, wallet_id: wallet_id)
        end
        
        run_test!
      end
    end
  end

  path '/api/v1/user/wallets/{wallet_id}/wallet_transactions/{id}' do
    parameter name: 'wallet_id', in: :path, type: :string, description: 'wallet_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show wallet transactions') do
      response(200, 'successful') do
        tags 'User Wallet Transactions'
        produces 'application/json'
        security [ { bearerAuth: nil } ]
        
        run_test!
      end
    end
  end
end