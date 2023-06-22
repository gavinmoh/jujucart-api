require 'swagger_helper'

RSpec.describe 'api/v1/user/registrations', type: :request do

  path '/api/v1/user/sign_up' do
    post('register users') do
      tags 'User Registrations'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              phone_number: { type: :string },
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
              profile_photo: { type: :string, description: 'Base64 encoded image' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { user: attributes_for(:user).slice(:name, :phone_number, :email, :profile_photo, :password) } }
        
        run_test! do |response|
          response_body = JSON.parse(response.body)
          id = response_body['user']['id']
          user = User.find(id)
          expect(user.current_workspace).to be_present
          expect(user.current_workspace.stores.count).to eq(1)
        end
      end
    end
    
  end
end