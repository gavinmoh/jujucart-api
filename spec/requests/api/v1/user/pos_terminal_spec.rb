require 'swagger_helper'

RSpec.describe 'api/v1/user/pos_terminals', type: :request do
  before do
    RevenueMonster.configure do |config|
      config.base_url = 'https://open.revenuemonster.my'
      config.oauth_url = 'https://oauth.revenuemonster.my'
      config.client_id = SecureRandom.alphanumeric(10)
      config.client_secret = SecureRandom.alphanumeric(10)
      config.private_key = OpenSSL::PKey::RSA.new(2048).to_s
    end
  end

  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:store) { create(:store, workspace: user.current_workspace) }
  let(:order) { create(:order, :with_line_items, order_type: 'pos', workspace: user.current_workspace) }
  let(:payment) { create(:payment, :revenue_monster, status: 'success', order_id: order.id) }
  let(:pos_terminal) { create(:pos_terminal, store_id: store.id) }
  let(:id) { pos_terminal.id }

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

  path '/api/v1/user/pos_terminals/{id}/initiate_payment' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('initiate pos terminal payment') do
      tags 'User Pos Terminals'
      security [ { bearerAuth: nil } ]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          payment: {
            type: :object,
            properties: {
              type: { type: :string, enum: ['CARD', 'E-WALLET'] },
              order_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:id) { pos_terminal.id }
        let(:data) { { payment: { type: 'CARD', order_id: order.id } } }

        before do
          order.pos_checkout!
        end

        run_test! do |_response|
          expect(order.reload.status).to eq('completed')
        end
      end
    end
  end

  path '/api/v1/user/pos_terminals/{id}/cancel_payment' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('cancel pos terminal payment') do
      tags 'User Pos Terminals'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { pos_terminal.id }

        run_test!
      end
    end
  end

  path '/api/v1/user/pos_terminals/{id}/card_payment_refund' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('refund pos terminal card payment') do
      tags 'User Pos Terminals'
      security [ { bearerAuth: nil } ]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          payment: {
            type: :object,
            properties: {
              id: { type: :string },
              reason: { type: :string },
              pin: { type: :string, description: 'Pin set in the pos terminal' },
              email: { type: :string, description: "Customer email required by revenue monster; this is required if order's customer does not have email" }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:id) { pos_terminal.id }
        let(:data) { { payment: { id: payment.id, reason: 'Wrong product', pin: '123456', email: Faker::Internet.email } } }

        before do
          order.update(status: 'completed')
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test! do |_response|
          expect(order.reload.status).to eq('refunded')
        end
      end
    end
  end
end