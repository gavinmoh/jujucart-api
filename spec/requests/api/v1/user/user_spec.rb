require 'swagger_helper'

RSpec.describe 'api/v1/user/users', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:user).id }

  path '/api/v1/user/users' do
    get('list users') do
      tags 'User Users'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :role, in: :query, type: :string, required: false, description: 'Filter by role'

      response(200, 'successful') do
        before do
          create_list(:user, 3)
        end

        run_test!
      end

    end

    post('create users') do
      tags 'User Users'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              name: { type: :string },
              phone_number: { type: :string },
              active: { type: :string },
              role: { type: :string, enum: User.roles.keys },
              profile_photo: { type: :string, description: 'Base64 encoded image' },
              assigned_stores_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    store_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { user: attributes_for(:user) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show users') do
      tags 'User Users'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update users') do
      tags 'User Users'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              name: { type: :string },
              phone_number: { type: :string },
              active: { type: :string },
              role: { type: :string, enum: User.roles.keys },
              profile_photo: { type: :string, description: 'Base64 encoded image' },
              remove_profile_photo: { type: :boolean, description: 'Set to true to remove profile photo' },
              assigned_stores_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    store_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { user: attributes_for(:user) } }      

        run_test!
      end
    end

    delete('delete users') do
      tags 'User Users'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end
    
  end
end