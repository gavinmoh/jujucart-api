require 'swagger_helper'

RSpec.describe 'api/v1/storefront/accounts', type: :request do
  # change the create(:user) to respective user model name
  let(:mock_request) { instance_double(ActionDispatch::Request) }
  let(:store) { create(:store, store_type: 'online') }
  let(:user) { create(:customer, workspace: store.workspace) }
  let(:Authorization) { bearer_token_for(user) }

  before do
    allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
  end

  path '/api/v1/storefront/accounts/' do
    get('show accounts') do
      response(200, 'successful') do
        tags 'Storefront Accounts'
        produces 'application/json'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end

    put('update accounts') do
      tags 'Storefront Accounts'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          account: {
            type: :object,
            properties: {
              name: { type: :string },
              phone_number: { type: :string },
              email: { type: :string },
              profile_photo: { type: :string, description: 'Base64 encoded image' },
              remove_profile_photo: { type: :boolean, description: 'Set to true to remove profile photo' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { account: attributes_for(:customer).slice(:name, :phone_number, :email) } }

        run_test!
      end
    end
  end

  path '/api/v1/storefront/accounts/password' do
    put('update password') do
      tags 'Storefront Accounts'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          account: {
            type: :object,
            properties: {
              current_password: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: [:current_password, :password]
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:current_password) { 'Currentpassword' }
        let(:new_password) { 'Newpassword' }
        let(:user) { create(:customer, workspace: store.workspace, password: 'Currentpassword') }
        let(:data) do
          { account: {
            current_password: current_password,
            password: new_password,
            password_confirmation: new_password
          } }
        end

        run_test!
      end
    end
  end
end
