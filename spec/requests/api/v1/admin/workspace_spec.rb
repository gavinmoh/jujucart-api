require 'swagger_helper'

RSpec.describe 'api/v1/admin/workspaces', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:workspace).id }

  path '/api/v1/admin/workspaces' do
    get('list workspaces') do
      tags 'Admin Workspaces'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'

      response(200, 'successful') do
        before do
          create_list(:workspace, 3)
        end

        run_test!
      end

    end

    post('create workspaces') do
      tags 'Admin Workspaces'
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
              owner_id: { type: :string },
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
    end

  end

  path '/api/v1/admin/workspaces/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show workspaces') do
      tags 'Admin Workspaces'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update workspaces') do
      tags 'Admin Workspaces'
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
              owner_id: { type: :string },
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
    end

    delete('delete workspaces') do
      tags 'Admin Workspaces'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end