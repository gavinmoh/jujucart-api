require 'swagger_helper'

RSpec.describe 'api/v1/user/inventories', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:inventory).id }

  path '/api/v1/user/inventories' do
    get('list inventories') do
      tags 'User Inventories'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Store ID'
      parameter name: :product_id, in: :query, type: :string, required: false, description: 'Product ID'

      response(200, 'successful') do
        before do
          create_list(:inventory, 5)
        end

        run_test!
      end

    end

    post('create inventories') do
      tags 'User Inventories'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory: {
            type: :object,
            properties: {
              product_id: { type: :string },
              store_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory: attributes_for(:inventory) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/inventories/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show inventories') do
      tags 'User Inventories'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update inventories') do
      tags 'User Inventories'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory: {
            type: :object,
            properties: {
              product_id: { type: :string },
              store_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory: attributes_for(:inventory) } }      

        run_test!
      end
    end

    delete('delete inventories') do
      tags 'User Inventories'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end