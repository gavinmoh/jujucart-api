require 'swagger_helper'

RSpec.describe 'api/v1/user/order_attachments', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:order_attachment).id }

  path '/api/v1/user/order_attachments' do
    get('list order attachments') do
      tags 'User Order Attachments'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :order_id, in: :query, type: :string, required: false, description: 'Order ID'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name'

      response(200, 'successful') do
        before do
          create_list(:order_attachment, 2)
        end

        run_test!
      end

    end

    post('create order attachments') do
      tags 'User Order Attachments'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order_attachment: {
            type: :object,
            properties: {
              order_id: { type: :string },
              file: { type: :string },
              name: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { order_attachment: attributes_for(:order_attachment) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/order_attachments/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show order attachments') do
      tags 'User Order Attachments'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update order attachments') do
      tags 'User Order Attachments'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order_attachment: {
            type: :object,
            properties: {
              order_id: { type: :string },
              file: { type: :string },
              name: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { order_attachment: attributes_for(:order_attachment) } }      

        run_test!
      end
    end

    delete('delete order attachments') do
      tags 'User Order Attachments'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end