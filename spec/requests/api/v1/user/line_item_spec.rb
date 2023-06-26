require 'swagger_helper'

RSpec.describe 'api/v1/admin/line_items', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:order) { create(:order, status: 'pending', order_type: 'pos', workspace: user.current_workspace) }
  let(:order_id) { order.id }
  let(:id) { create(:line_item, order_id: order_id).id }

  path '/api/v1/user/orders/{order_id}/line_items' do
    parameter name: 'order_id', in: :path, type: :string, description: 'order_id'

    get('list line items') do
      tags 'User Line Items'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        before do
          create_list(:line_item, 3, order_id: order_id)
        end

        run_test!
      end
    end

    post('create line items') do
      tags 'User Line Items'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          line_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :integer },
              name: { type: :string },
              unit_price: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:data) { { line_item: attributes_for(:line_item) } }

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['quantity']).to eq(data[:line_item][:quantity])
        end
      end

      context 'when manual order' do
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'manual', status: 'pending') }
        let(:product) { create(:product, price_cents: 1000, discount_price_cents: 0) }

        it 'allows setting name and unit price' do
          expect do
            post api_v1_user_order_line_items_url(order_id: order.id), headers: { Authorization: bearer_token_for(user) },
                                                                       params: { line_item: { product_id: product.id, quantity: 1, name: 'test', unit_price: 1 } }
          end.to change(LineItem, :count).by(1)
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['name']).to eq('test')
          expect(response_body['line_item']['unit_price']['cents']).to eq(100)
        end
      end

      context 'when pos order' do
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'pos', status: 'pending') }
        let(:product) { create(:product, workspace: user.current_workspace, price_cents: 1000, discount_price_cents: 0) }

        it 'does not allow setting name and unit price' do
          expect do
            post api_v1_user_order_line_items_url(order_id: order.id), headers: { Authorization: bearer_token_for(user) },
                                                                       params: { line_item: { product_id: product.id, quantity: 1, name: 'test', unit_price: 100 } }
          end.to change(LineItem, :count).by(1)
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['name']).to eq(product.name)
          expect(response_body['line_item']['unit_price']['cents']).to eq(product.price.cents)
        end
      end
    end
  end

  path '/api/v1/user/orders/{order_id}/line_items/{id}' do
    parameter name: 'order_id', in: :path, type: :string, description: 'order_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show line items') do
      response(200, 'successful') do
        tags 'User Line Items'
        produces 'application/json'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end

    put('update line items') do
      tags 'User Line Items'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          line_item: {
            type: :object,
            properties: {
              product_id: { type: :string },
              quantity: { type: :integer },
              name: { type: :string },
              unit_price: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:data) { { line_item: attributes_for(:line_item) } }

        run_test!
      end

      context 'when line item update met coupon minimum spend' do
        let(:user) { create(:user, role: 'cashier') }
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'pos', status: 'pending') }
        let(:order_id) { order.id }
        let(:id) { create(:line_item, order_id: order_id, quantity: 1).id }

        before do
          create(:assigned_store, user_id: user.id, store_id: order.store_id)
          create_list(:line_item, 2, order_id: order.id)
          id
        end

        it 'applies discount' do
          order.reload
          coupon = create(:coupon, workspace: user.current_workspace, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100))
          OrderCoupon.create(order: order, coupon_id: coupon.id, code: coupon.code)
          order.reload

          expect(order.valid_order_coupon).to be_nil
          expect(order.discount.cents).to eq(0)
          expect(order.order_coupon.discount.cents).to eq(0)

          put api_v1_user_order_line_item_url(order_id: order.id, id: id), headers: { Authorization: bearer_token_for(user) }, params: { line_item: { quantity: 2 } }
          order.reload
          calculated_discount = order.subtotal * coupon.discount_percentage / 100
          expect(order.valid_order_coupon).to be_present
          expect(order.discount.cents).to eq(calculated_discount.cents)
          expect(order.order_coupon.discount.cents).to eq(calculated_discount.cents)
        end
      end

      context 'when line item update does not met coupon minimum spend' do
        let(:user) { create(:user, role: 'cashier') }
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'pos', status: 'pending') }
        let(:order_id) { order.id }
        let(:id) { create(:line_item, order_id: order_id, quantity: 2).id }

        before do
          create(:assigned_store, user_id: user.id, store_id: order.store_id)
          create_list(:line_item, 2, order_id: order.id)
          id
        end

        it 'applies discount' do
          order.reload
          coupon = create(:coupon, workspace: user.current_workspace, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal)
          OrderCoupon.create(order: order, coupon_id: coupon.id, code: coupon.code)
          order.reload

          calculated_discount = order.subtotal * coupon.discount_percentage / 100
          expect(order.valid_order_coupon).to be_present
          expect(order.discount.cents).to eq(calculated_discount.cents)
          expect(order.order_coupon.discount.cents).to eq(calculated_discount.cents)

          put api_v1_user_order_line_item_url(order_id: order.id, id: id), headers: { Authorization: bearer_token_for(user) }, params: { line_item: { quantity: 1 } }
          order.reload
          expect(order.valid_order_coupon).to be_nil
          expect(order.discount.cents).to eq(0)
          expect(order.order_coupon.discount.cents).to eq(0)
        end
      end

      context 'when manual order' do
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'manual', status: 'pending') }
        let(:product) { create(:product, workspace: user.current_workspace, price_cents: 100, discount_price_cents: 0) }
        let(:id) { create(:line_item, product_id: product.id, order_id: order.id).id }

        it 'allows overriding unit price and name' do
          put api_v1_user_order_line_item_url(order_id: order.id, id: id), headers: { Authorization: bearer_token_for(user) }, params: { line_item: { name: 'test', unit_price: 10 } }
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['name']).to eq('test')
          expect(response_body['line_item']['unit_price']['cents']).to eq(1000)
        end
      end

      context 'when pos order' do
        let(:order) { create(:order, workspace: user.current_workspace, order_type: 'pos', status: 'pending') }
        let(:product) { create(:product, workspace: user.current_workspace, price_cents: 100, discount_price_cents: 0) }
        let(:id) { create(:line_item, product_id: product.id, order_id: order.id).id }

        it 'does not allow overriding unit price and name' do
          put api_v1_user_order_line_item_url(order_id: order.id, id: id), headers: { Authorization: bearer_token_for(user) }, params: { line_item: { name: 'test', unit_price: 10 } }
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body['line_item']['name']).to eq(product.name)
          expect(response_body['line_item']['unit_price']['cents']).to eq(product.price_cents)
        end
      end
    end

    delete('delete line items') do
      response(204, 'successful') do
        tags 'User Line Items'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end
  end
end
