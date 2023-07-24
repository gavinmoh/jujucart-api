require 'swagger_helper'

RSpec.describe 'api/v1/storefront/line_items', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:customer) }
  let(:Authorization) { bearer_token_for(user) }
  let!(:store) { create(:store, workspace: user.workspace, store_type: 'online') }
  let(:order) { create(:order, :guest_order, store_id: store.id, workspace: user.workspace) }
  let(:order_id) { order.id }
  let(:id) { create(:line_item, order_id: order_id).id }
  let(:mock_request) { instance_double(ActionDispatch::Request) }

  before do
    allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
  end

  path '/api/v1/storefront/orders/{order_id}/line_items' do
    parameter name: 'order_id', in: :path, type: :string, description: 'order_id'

    get('list line items') do
      tags 'Storefront Line Items'
      # security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        before do
          create_list(:line_item, 3, order_id: order_id)
        end

        run_test!
      end

      response(403, 'forbidden') do
        let(:order_id) { create(:order, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end
    end

    post('create line items') do
      tags 'Storefront Line Items'
      produces 'application/json'
      consumes 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          line_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :integer },
              line_item_addons_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    product_addon_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:product) { create(:product, workspace: user.workspace) }
        let(:product_addon) { create(:product_addon, product: product) }
        let(:data) do
          { line_item: { product_id: product.id, quantity: 1, line_item_addons_attributes: [{ product_addon_id: product_addon.id }] } }
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['quantity']).to eq(data[:line_item][:quantity])
          line_item = LineItem.find(response_body['line_item']['id'])
          expect(line_item.total_price).to eq((line_item.product_unit_price + line_item.line_item_addons_price) * line_item.quantity)
        end
      end

      response(403, 'forbidden') do
        let(:order_id) { create(:order, store_id: store.id, workspace: user.workspace).id }
        let(:data) { { line_item: attributes_for(:line_item) } }

        run_test!
      end
    end
  end

  path '/api/v1/storefront/orders/{order_id}/line_items/{id}' do
    parameter name: 'order_id', in: :path, type: :string, description: 'order_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show line items') do
      tags 'Storefront Line Items'
      produces 'application/json'
      # security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:order_id) { create(:order, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end
    end

    put('update line items') do
      tags 'Storefront Line Items'
      produces 'application/json'
      consumes 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          line_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :integer },
              line_item_addons_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    product_addon_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      let(:data) { { line_item: attributes_for(:line_item) } }

      response(200, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:order_id) { create(:order, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end

      context 'when line item update met coupon minimum spend' do
        it 'applies discount' do
          order = create(:order, :guest_order, store_id: store.id, workspace: user.workspace)
          line_item = create(:line_item, order_id: order.id, quantity: 1)

          order.reload
          coupon = create(:coupon, workspace: user.workspace, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100))
          OrderCoupon.create(order: order, coupon_id: coupon.id, code: coupon.code)
          order.reload

          expect(order.valid_order_coupon).to be_nil
          expect(order.discount.cents).to eq(0)
          expect(order.order_coupon.discount.cents).to eq(0)

          put api_v1_storefront_order_line_item_url(order_id: order.id, id: line_item.id), params: { line_item: { quantity: 2 } }
          order.reload
          calculated_discount = order.subtotal * coupon.discount_percentage / 100
          expect(order.valid_order_coupon).to be_present
          expect(order.discount.cents).to eq(calculated_discount.cents)
          expect(order.order_coupon.discount.cents).to eq(calculated_discount.cents)
        end
      end

      context 'when line item update does not met coupon minimum spend' do
        it 'does not applies discount' do
          order = create(:order, :with_line_items, :guest_order, store_id: store.id, workspace: user.workspace)
          line_item = create(:line_item, order_id: order.id, quantity: 2)

          order.reload
          coupon = create(:coupon, workspace: user.workspace, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal)
          OrderCoupon.create(order: order, coupon_id: coupon.id, code: coupon.code)
          order.reload

          calculated_discount = order.subtotal * coupon.discount_percentage / 100
          expect(order.valid_order_coupon).to be_present
          expect(order.discount.cents).to eq(calculated_discount.cents)
          expect(order.order_coupon.discount.cents).to eq(calculated_discount.cents)

          put api_v1_storefront_order_line_item_url(order_id: order.id, id: line_item.id), params: { line_item: { quantity: 1 } }
          order.reload

          expect(order.valid_order_coupon).to be_nil
          expect(order.discount.cents).to eq(0)
          expect(order.order_coupon.discount.cents).to eq(0)
        end
      end
    end

    delete('delete line items') do
      tags 'Storefront Line Items'
      # security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
