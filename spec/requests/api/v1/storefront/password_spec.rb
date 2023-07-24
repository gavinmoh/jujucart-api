require 'swagger_helper'

RSpec.describe 'api/v1/storefront/passwords', type: :request do
  let!(:store) { create(:store, store_type: 'online') }
  let(:mock_request) { instance_double(ActionDispatch::Request) }

  before do
    allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
  end

  path '/api/v1/storefront/passwords' do
    post('Send Reset Password Token') do
      tags 'Storefront Reset Passwords'
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
        let(:data) do
          {
            customer: {
              email: create(:customer, workspace: store.workspace).email
            }
          }
        end

        run_test!
      end

      response(422, 'wrong email/phone number') do
        let(:data) do
          {
            user: {
              email: 'wrong_email@email.com'
            }
          }
        end
        run_test!
      end
    end

    put('Reset Password with Token') do
      tags 'Storefront Reset Passwords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
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
        let(:data) do
          {
            customer: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        before do
          customer = create(:customer, workspace: store.workspace)
          hashed_token = Devise.token_generator.digest(customer, :reset_password_token, 123_456)
          customer.assign_attributes(
            reset_password_token: hashed_token,
            reset_password_sent_at: Time.now.utc
          )
          customer.save(validate: false)
        end

        run_test!
      end

      response(422, 'wrong token') do
        let(:data) do
          {
            customer: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        run_test!
      end
    end
  end
end
