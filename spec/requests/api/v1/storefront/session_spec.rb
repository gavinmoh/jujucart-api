require 'swagger_helper'

RSpec.describe 'api/v1/storefront/sessions', type: :request do
  let!(:store) { create(:store, store_type: 'online', hostname: 'www.example.com') }
  let(:customer) { create(:customer, workspace: store.workspace, password: 'password') }

  path '/api/v1/storefront/sign_in' do
    post('Sign in') do
      tags 'Storefront Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@test.com' },
              password: { type: :string, example: 'password' }
            },
            required: %w[email password]
          }
        }
      }
      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', type: :string

        let(:data) do
          {
            customer: {
              email: customer.email,
              password: 'password'
            }
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:another_customer) { create(:customer, email: customer.email, password: 'differentpassword') }
        let(:data) do
          {
            customer: {
              email: customer.email,
              password: 'differentpassword'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/storefront/sign_out' do
    delete('Sign out') do
      tags 'Storefront Sessions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        let(:Authorization) { bearer_token_for(create(:customer, workspace: store.workspace)) }

        run_test!
      end
    end
  end
end
