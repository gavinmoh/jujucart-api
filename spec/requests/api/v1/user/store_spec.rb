require 'swagger_helper'

RSpec.describe 'api/v1/user/stores', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:store).id }

  path '/api/v1/user/stores' do
    get('list stores') do
      tags 'User Stores'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'

      response(200, 'successful') do
        before do
          create_list(:store, 2)
        end

        run_test!
      end

    end

    post('create stores') do
      tags 'User Stores'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          store: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              logo: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { store: attributes_for(:store) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/stores/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show stores') do
      tags 'User Stores'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update stores') do
      tags 'User Stores'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          store: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              logo: { type: :string },
              remove_logo: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { store: attributes_for(:store) } }      

        run_test!
      end
    end

    delete('delete stores') do
      tags 'User Stores'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end