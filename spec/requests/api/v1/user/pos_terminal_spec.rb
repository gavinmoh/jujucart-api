require 'swagger_helper'

RSpec.describe 'api/v1/user/pos_terminals', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:pos_terminal).id }

  path '/api/v1/user/pos_terminals' do

    get('list pos terminals') do
      tags 'User Pos Terminals'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Store id'

      response(200, 'successful') do
        before do
          create_list(:pos_terminal, 3)
        end

        run_test!
      end

    end

    post('create pos terminals') do
      tags 'User Pos Terminals'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          pos_terminal: {
            type: :object,
            properties: {
              store_id: { type: :string },
              terminal_id: { type: :string },
              label: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { pos_terminal: attributes_for(:pos_terminal) } }
        
        run_test!
      end
    end

  end

  path '/api/v1/user/pos_terminals/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show pos terminals') do
      response(200, 'successful') do
        tags 'User Pos Terminals'
        produces 'application/json'
        security [ { bearerAuth: nil } ]

        run_test!
      end
    end

    put('update pos terminals') do
      tags 'User Pos Terminals'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          pos_terminal: {
            type: :object,
            properties: {
              store_id: { type: :string },
              terminal_id: { type: :string },
              label: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { pos_terminal: attributes_for(:pos_terminal) } }
        
        run_test!
      end
    end

    delete('delete pos terminals') do
      response(204, 'successful') do
        tags 'User Pos Terminals'
        security [ { bearerAuth: nil } ]

        run_test!
      end
    end

    
  end
end