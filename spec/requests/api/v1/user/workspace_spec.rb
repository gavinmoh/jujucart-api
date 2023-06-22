require 'swagger_helper'

RSpec.describe 'api/v1/user/workspace', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/workspace/' do
    get('show workspace') do
      response(200, 'successful') do
        tags 'User Workspace'
        produces 'application/json'
        security [ { bearerAuth: nil } ]

        run_test!
      end
    end

    put('update workspace') do
      tags 'User Workspace'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          workspace: {
            type: :object,
            properties: {
              name: { type: :string },
              logo: { type: :string },
              subdomain: { type: :string },
              web_host: { type: :string },
              coin_to_cash_rate: { type: :float },
              order_reward_amount: { type: :integer },
              maximum_redeemed_coin_rate: { type: :float },
              invoice_size: { type: :string },
              company_phone_number: { type: :string }, 
              company_email: { type: :string }, 
              company_name: { type: :string }, 
              company_address: { type: :string }, 
              bank_name: { type: :string }, 
              bank_account_number: { type: :string },
              bank_holder_name: { type: :string }, 
              receipt_footer: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { workspace: attributes_for(:workspace) } }
        
        run_test!
      end

      response(403, 'forbidden') do
        let(:data) { { workspace: attributes_for(:workspace) } }
        let(:other_user) { create(:user) }
        let(:Authorization) { bearer_token_for(other_user) }

        before do
          other_user.user_workspaces.destroy_all
          other_user.user_workspaces.create(workspace: user.current_workspace)
        end
        
        run_test!
      end
    end
    
  end
end