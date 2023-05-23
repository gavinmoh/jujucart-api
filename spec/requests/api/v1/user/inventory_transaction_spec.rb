require 'swagger_helper'

RSpec.describe 'api/v1/user/inventory_transactions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:inventory_transaction).id }

  path '/api/v1/user/inventory_transactions' do
    get('list inventory transactions') do
      tags 'User Inventory Transactions'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :inventory_id, in: :query, type: :string, required: false, description: 'Inventory ID'

      response(200, 'successful') do
        before do
          create_list(:inventory_transaction, 5)
        end

        run_test!
      end

    end

    post('create inventory transactions') do
      tags 'User Inventory Transactions'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transaction: {
            type: :object,
            properties: {
              inventory_id: { type: :string },
              quantity: { type: :integer },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory_transaction: attributes_for(:inventory_transaction) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/inventory_transactions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show inventory transactions') do
      tags 'User Inventory Transactions'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update inventory transactions') do
      tags 'User Inventory Transactions'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transaction: {
            type: :object,
            properties: {
              inventory_id: { type: :string },
              quantity: { type: :integer },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory_transaction: attributes_for(:inventory_transaction) } }      

        run_test!
      end
    end

    delete('delete inventory transactions') do
      tags 'User Inventory Transactions'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end

  path '/api/v1/user/inventory_transactions/adjustment' do
    put('adjust item quantity') do
      tags 'User Inventory Transactions'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transaction: {
            type: :object,
            properties: {
              store_id: { type: :string },
              product_id: { type: :string },
              quantity: { type: :integer },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory_transaction: {
          location_id: create(:store).location.id, 
          product_id: create(:product).id, 
          quantity: Faker::Number.within(range: 1..100),
          description: Faker::Lorem.sentence
        } } }

        run_test!
      end
    end
  end
end