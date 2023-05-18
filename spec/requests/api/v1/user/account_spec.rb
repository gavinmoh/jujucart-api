require 'swagger_helper'

RSpec.describe 'api/v1/user/accounts', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/accounts/' do
    get('show accounts') do
      response(200, 'successful') do
        tags 'User Accounts'
        produces 'application/json'
        security [ { bearerAuth: nil } ]

        run_test!
      end
    end

    put('update accounts') do
      tags 'User Accounts'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

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
        let(:data) { { account: attributes_for(:user).slice(:name, :phone_number, :email) } }
        
        run_test!
      end
    end
    
  end

  path '/api/v1/user/accounts/password' do
    put('update password') do
      tags 'User Accounts'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

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
        let(:user) { create(:user, password: 'Currentpassword') }
        let(:data) { { account: {
          current_password: current_password,
          password: new_password,
          password_confirmation: new_password
        } } }
        
        run_test!
      end
    end
  end
end