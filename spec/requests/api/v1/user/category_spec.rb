require 'swagger_helper'

RSpec.describe 'api/v1/user/categories', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:category).id }

  path '/api/v1/user/categories' do
    get('list categories') do
      tags 'User Categories'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'

      response(200, 'successful') do
        before do
          create_list(:category, 10)
        end

        run_test!
      end

    end

    post('create categories') do
      tags 'User Categories'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              display_order: { type: :string },
              photo: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { category: attributes_for(:category) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/categories/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show categories') do
      tags 'User Categories'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update categories') do
      tags 'User Categories'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              display_order: { type: :string },
              photo: { type: :string },
              remove_photo: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { category: attributes_for(:category) } }      

        run_test!
      end
    end

    delete('delete categories') do
      tags 'User Categories'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end