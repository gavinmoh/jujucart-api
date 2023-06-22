require 'swagger_helper'

RSpec.describe 'api/v1/user/promotion_bundles', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:promotion_bundle, workspace: user.current_workspace).id }
  let!(:promotion_bundle_item) { create(:promotion_bundle_item, promotion_bundle_id: id) }

  path '/api/v1/user/promotion_bundles' do
    get('list promotion bundles') do
      tags 'User Promotion Bundles'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      parameter name: :scope, in: :query, type: :string, required: false, description: "Filter by scope, available scope: 'active', 'expired', 'scheduled'"
      parameter name: :product_id, in: :query, type: :string, required: false, description: "Filter promotion bundles contains the product"

      response(200, 'successful') do
        before do
          3.times do
            promotion_bundle = create(:promotion_bundle, workspace: user.current_workspace)
            create(:promotion_bundle_item, promotion_bundle_id: promotion_bundle.id)
          end
        end

        run_test!
      end

    end

    post('create promotion bundles') do
      tags 'User Promotion Bundles'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          promotion_bundle: {
            type: :object,
            properties: {
              name: { type: :string },
              discount_by: { type: :string, enum: PromotionBundle.discount_bies.keys },
              discount_price: { type: :string },
              discount_percentage: { type: :integer },
              start_at: { type: :string },
              end_at: { type: :string },
              active: { type: :boolean },
              promotion_bundle_items_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    product_id: { type: :string },
                    quantity: { type: :integer }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { promotion_bundle: attributes_for(:promotion_bundle).merge(
          promotion_bundle_items_attributes: [attributes_for(:promotion_bundle_item).slice(:product_id, :quantity)]
        ) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/promotion_bundles/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show promotion bundles') do
      tags 'User Promotion Bundles'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update promotion bundles') do
      tags 'User Promotion Bundles'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          promotion_bundle: {
            type: :object,
            properties: {
              name: { type: :string },
              discount_by: { type: :string, enum: PromotionBundle.discount_bies.keys },
              discount_price: { type: :string },
              discount_percentage: { type: :integer },
              start_at: { type: :string },
              end_at: { type: :string },
              active: { type: :boolean },
              promotion_bundle_items_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    product_id: { type: :string },
                    quantity: { type: :integer }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { promotion_bundle: attributes_for(:promotion_bundle) } }      

        run_test!
      end
    end

    delete('delete promotion bundles') do
      tags 'User Promotion Bundles'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end