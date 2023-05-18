require 'swagger_helper'

RSpec.describe 'api/v1/user/settings', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/settings' do

    get('show all settings') do
      tags 'User Settings'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update settings') do
      tags 'User Settings'
      security [ { bearerAuth: nil } ]
      produces 'application/json'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object, 
        properties: {
          setting: {
            type: :object,
            properties: {
              web_host: { type: :string },
              coin_to_cash_rate: { type: :float },
              order_reward_amount: { type: :integer },
              maximum_redeemed_coin_rate: { type: :float }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { 
          setting: { 
            web_host: "https://app.jujucart.com",
            coin_to_cash_rate: 0.01,
            order_reward_amount: 10,
            maximum_redeemed_coin_rate: 0.5,
          }
        }}
        
        run_test!
      end
    end
  end
end