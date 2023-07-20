require 'swagger_helper'

RSpec.describe 'api/v1/storefront/registrations', type: :request do
  let!(:store) { create(:store, store_type: 'online', hostname: 'www.example.com') }

  path '/api/v1/storefront/sign_up' do
    post('register customer') do
      tags 'Storefront Registrations'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              name: { type: :string },
              phone_number: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', type: :string

        let(:data) { { customer: attributes_for(:customer).slice(:email, :password, :name, :phone_number) } }

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['customer']['email']).to eq(data[:customer][:email])
          expect(response_body['customer']['workspace_id']).to eq(store.workspace_id)
        end
      end

      response(422, 'unprocessable entity', save_request_example: :data) do
        let!(:existing_customer) { create(:customer, workspace: store.workspace) }
        let(:data) { { customer: attributes_for(:customer, email: existing_customer.email).slice(:email, :password, :name, :phone_number) } }

        run_test!
      end
    end
  end
end
