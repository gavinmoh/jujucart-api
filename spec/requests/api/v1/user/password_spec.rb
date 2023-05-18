require 'swagger_helper'

RSpec.describe 'api/v1/user/passwords', type: :request do

  path '/api/v1/user/passwords' do

    post('Send Reset Password Token') do
      tags 'User Reset Passwords'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: 'email', example: 'user@test.com' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { {
          user: {
              email: create(:user).email
            } 
        } }

        run_test!
      end

      response(422, 'wrong email/phone number') do
        let(:data) { {
          user: {
              email: 'wrong_email@email.com'
            } 
          } }
        run_test!        
      end
    end

    put('Reset Password with Token') do
      tags 'User Reset Passwords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              reset_password_token: { type: :string },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' }
            },
            required: [:password, :reset_password_token]
          }
        }
      }
      response(200, 'successful', save_request_example: :data) do
        let(:data) { {
          user: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            } 
        } }

        before do
          user = create(:user)
          hashed_token = Devise.token_generator.digest(user, :reset_password_token, 123456)
          user.assign_attributes(
            reset_password_token: hashed_token,
            reset_password_sent_at: Time.now.utc
          )
          user.save(validate: false)
        end

        run_test!
      end

      response(422, 'wrong token') do
        let(:data) { {
          user: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            } 
        } }
        
        run_test!        
      end
    end

  end
end
