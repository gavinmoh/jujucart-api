require 'swagger_helper'

RSpec.describe 'api/v1/user/locations', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:location, store: nil).id }

  path '/api/v1/user/locations' do
    get('list locations') do
      tags 'User Locations'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :exclude_store, in: :query, type: :string, required: false, description: 'Exclude Store location'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name or store_name'

      response(200, 'successful') do
        before do
          create_list(:location, 3, store: nil)
          create_list(:store, 3)
        end

        run_test!
      end

    end

    post('create locations') do
      tags 'User Locations'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          location: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { location: attributes_for(:location) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/locations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show locations') do
      tags 'User Locations'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update locations') do
      tags 'User Locations'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          location: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { location: attributes_for(:location) } }      

        run_test!
      end
    end

    delete('delete locations') do
      tags 'User Locations'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end