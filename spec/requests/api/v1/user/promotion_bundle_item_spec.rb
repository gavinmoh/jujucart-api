require 'swagger_helper'

RSpec.describe 'api/v1/user/promotion_bundle_items', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:promotion_bundle_id) { create(:promotion_bundle, workspace: user.current_workspace).id }
  let(:id) { create(:promotion_bundle_item, promotion_bundle_id: promotion_bundle_id).id }

  path '/api/v1/user/promotion_bundles/{promotion_bundle_id}/promotion_bundle_items' do
    parameter name: 'promotion_bundle_id', in: :path, type: :string, description: 'promotion_bundle_id'

    get('list promotion bundle items') do
      tags 'User Promotion Bundle Items'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        before do
          create_list(:promotion_bundle_item, 2, promotion_bundle_id: promotion_bundle_id)
        end

        run_test!
      end

    end

    post('create promotion bundle items') do
      tags 'User Promotion Bundle Items'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          promotion_bundle_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { promotion_bundle_item: attributes_for(:promotion_bundle_item).slice(:product_id, :quantity) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/promotion_bundles/{promotion_bundle_id}/promotion_bundle_items/{id}' do
    parameter name: 'promotion_bundle_id', in: :path, type: :string, description: 'promotion_bundle_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show promotion bundle items') do
      tags 'User Promotion Bundle Items'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update promotion bundle items') do
      tags 'User Promotion Bundle Items'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          promotion_bundle_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { promotion_bundle_item: attributes_for(:promotion_bundle_item) } }      

        run_test!
      end
    end

    delete('delete promotion bundle items') do
      tags 'User Promotion Bundle Items'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end