require 'swagger_helper'

RSpec.describe 'api/v1/storefront/orders', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:customer) }
  let(:Authorization) { bearer_token_for(user) }
  let(:workspace) { user.workspace }
  let!(:store) { create(:store, workspace: user.workspace, store_type: 'online') }
  let(:id) { create(:order, :guest_order, store_id: store.id, workspace: user.workspace).id }
  let(:mock_request) { instance_double(ActionDispatch::Request) }
  
  before do
    allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  path '/api/v1/storefront/orders' do
    get('list orders') do
      tags 'Storefront Orders'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page,            in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items,           in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :query,           in: :query, type: :string,  required: false, description: "Search by order_number"
      parameter name: :status,          in: :query, type: :string,  required: false, description: "Filter by status, available status: #{Order.aasm.states.map(&:name).map(&:to_s).join(', ')}"
      parameter name: :order_type,      in: :query, type: :string, required: false, description: "Filter by order_type, available order_type: #{Order.order_types.keys.join(', ')}"
      parameter name: :scope,           in: :query, type: :string, required: false, description: "Filter by scope, available scope: ['delivery', 'pickup']"
      parameter name: :filter_date_by,  in: :query, type: :string,  required: false, description: 'Filter by which date column, e.g. created_at, updated_at'
      parameter name: :from_date,       in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :to_date,         in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :store_id,        in: :query, type: :string, required: false, description: 'Filter by store_id'
      parameter name: :sort_by,         in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order,      in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        before do
          create_list(:order, 3, store_id: store.id, customer_id: user.id, status: 'confirmed', workspace: user.workspace)
        end

        run_test!
      end
    end

    post('create orders') do
      tags 'Storefront Orders'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              order_type: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { order: attributes_for(:order, order_type: 'delivery').slice(:order_type) } }

        run_test!
      end

      context 'when customer is signed in' do
        it 'creates an order with customer_id' do
          post api_v1_storefront_orders_path, params: { order: attributes_for(:order, order_type: 'delivery').slice(:order_type) },
                                              headers: { Authorization: bearer_token_for(user) }, as: :json
          response_body = JSON.parse(response.body)
          expect(response_body['order']['customer_id']).to eq(user.id)
          expect(response_body['order']['created_by_id']).to eq(user.id)
        end
      end
    end
  end

  path '/api/v1/storefront/orders/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show orders') do
      tags 'Storefront Orders'
      produces 'application/json'
      # security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, store_id: store.id, workspace: user.workspace).id }
        run_test!
      end
    end

    put('update orders') do
      tags 'Storefront Orders'
      produces 'application/json'
      consumes 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              billing_address_unit_number: { type: :string },
              billing_address_street_address1: { type: :string },
              billing_address_street_address2: { type: :string },
              billing_address_postcode: { type: :string },
              billing_address_city: { type: :string },
              billing_address_state: { type: :string },
              billing_address_country: { type: :string },
              billing_address_latitude: { type: :number },
              billing_address_longitude: { type: :number },
              billing_address_contact_name: { type: :string },
              billing_address_contact_email: { type: :string },
              billing_address_contact_phone_number: { type: :string },
              delivery_address_unit_number: { type: :string },
              delivery_address_street_address1: { type: :string },
              delivery_address_street_address2: { type: :string },
              delivery_address_postcode: { type: :string },
              delivery_address_city: { type: :string },
              delivery_address_state: { type: :string },
              delivery_address_country: { type: :string },
              delivery_address_latitude: { type: :number },
              delivery_address_longitude: { type: :number },
              delivery_address_contact_name: { type: :string },
              delivery_address_contact_email: { type: :string },
              delivery_address_contact_phone_number: { type: :string },
              redeemed_coin: { type: :integer },
              order_attachments_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    name: { type: :string },
                    file: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      let(:data) do
        { order: attributes_for(:order).slice(:delivery_street_address1, :delivery_street_address2)
                                       .merge(order_attachments_attributes: [
                                                attributes_for(:order_attachment).slice(:name, :file)
                                              ]) }
      end

      response(200, 'successful', save_request_example: :data) do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, :guest_order, store_id: store.id, status: 'completed', workspace: user.workspace).id }

        run_test!
      end
    end

    delete('delete orders') do
      tags 'Storefront Orders'
      # security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, :guest_order, store_id: store.id, status: 'completed', workspace: user.workspace).id }

        run_test!
      end
    end
  end

  path '/api/v1/storefront/orders/{id}/checkout' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('checkout orders') do
      tags 'Storefront Orders'
      produces 'application/json'
      consumes 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, required: false, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              billing_address_unit_number: { type: :string },
              billing_address_street_address1: { type: :string },
              billing_address_street_address2: { type: :string },
              billing_address_postcode: { type: :string },
              billing_address_city: { type: :string },
              billing_address_state: { type: :string },
              billing_address_country: { type: :string },
              billing_address_latitude: { type: :number },
              billing_address_longitude: { type: :number },
              billing_address_contact_name: { type: :string },
              billing_address_contact_email: { type: :string },
              billing_address_contact_phone_number: { type: :string },
              delivery_address_unit_number: { type: :string },
              delivery_address_street_address1: { type: :string },
              delivery_address_street_address2: { type: :string },
              delivery_address_postcode: { type: :string },
              delivery_address_city: { type: :string },
              delivery_address_state: { type: :string },
              delivery_address_country: { type: :string },
              delivery_address_latitude: { type: :number },
              delivery_address_longitude: { type: :number },
              delivery_address_contact_name: { type: :string },
              delivery_address_contact_email: { type: :string },
              delivery_address_contact_phone_number: { type: :string },
              redeemed_coin: { type: :integer }
            }
          }
        }
      }

      let(:id) { create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace).id }

      response(200, 'successful') do
        context 'when default_payment_gateway is Billplz' do
          before { workspace.update(default_payment_gateway: 'Billplz') }

          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['order']['status']).to eq('pending_payment')
            expect(response_body['order']['payment_url']).to be_present
          end
        end

        context 'when default_payment_gateway is Stripe' do
          before { workspace.update(default_payment_gateway: 'Stripe', stripe_account_id: '123', stripe_charges_enabled: true) }

          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['order']['status']).to eq('pending_payment')
            expect(response_body['order']['payment_url']).to be_present
          end
        end
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, :with_line_items, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end

      context 'when customer is signed in' do
        it 'updates the order with customer_id' do
          put checkout_api_v1_storefront_order_path(id), headers: { Authorization: bearer_token_for(user) }
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body['order']['customer_id']).to eq(user.id)
          expect(response_body['order']['created_by_id']).to eq(user.id)
        end
      end
    end
  end

  path '/api/v1/storefront/orders/{id}/complete' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('complete orders') do
      tags 'Storefront Orders'
      produces 'application/json'
      # consumes 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:id) { create(:order, customer_id: user.id, store_id: store.id, status: 'shipped', workspace: user.workspace).id }

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'status')).to eq('completed')
        end
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, store_id: store.id, status: 'shipped', workspace: user.workspace).id }

        run_test!
      end
    end
  end

  path '/api/v1/storefront/orders/{id}/apply_coupon' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('apply coupon to orders') do
      tags 'Storefront Orders'
      consumes 'application/json'
      produces 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          code: { type: :string }
        },
        required: ['code']
      }

      let(:id) { create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace).id }
      let(:code) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: user.workspace).code }
      let(:data) { { code: code } }

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          response_body = JSON.parse(response.body)
          subtotal = Money.new(response_body.dig('order', 'subtotal', 'cents'))
          expected_discount = subtotal * 0.1
          expect(response_body.dig('order', 'order_coupon')).to be_present
          expect(response_body.dig('order', 'order_coupon', 'code')).to eq(code)
          expect(response_body.dig('order', 'order_coupon', 'discount', 'cents')).to eq(expected_discount.cents)
          expect(response_body.dig('order', 'discount', 'cents')).to eq(expected_discount.cents)
        end
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, :with_line_items, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end

      response(404, 'not_found') do
        let(:data) { { code: SecureRandom.alphanumeric(10) } }
        run_test!
      end
    end

    context 'when minimum spend is not met' do
      it 'does not apply discount' do
        order = create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace)
        code = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100), workspace: user.workspace).code

        put apply_coupon_api_v1_storefront_order_url(order), params: { code: code }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.dig('order', 'order_coupon')).to be_present
        expect(parsed_response.dig('order', 'order_coupon', 'code')).to eq(code)
        expect(parsed_response.dig('order', 'order_coupon', 'is_valid')).to be_falsey
        expect(parsed_response.dig('order', 'order_coupon', 'error_code')).to eq(OrderCoupon.error_codes[:minimum_spend_not_reached])
        expect(parsed_response.dig('order', 'order_coupon', 'discount', 'cents')).to eq(0)
        expect(parsed_response.dig('order', 'discount', 'cents')).to eq(0)
      end
    end

    context 'when code limit reached' do
      it 'does not apply discount' do
        order = create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace)
        coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, redemption_limit: 1, workspace: user.workspace)
        code = coupon.code
        create(:order_coupon, order_id: create(:order, workspace: user.workspace, status: 'confirmed').id, coupon_id: coupon.id, error_code: 'code_valid', is_valid: true)

        put apply_coupon_api_v1_storefront_order_url(order), params: { code: code }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.dig('order', 'order_coupon')).to be_present
        expect(parsed_response.dig('order', 'order_coupon', 'code')).to eq(code)
        expect(parsed_response.dig('order', 'order_coupon', 'is_valid')).to be_falsey
        expect(parsed_response.dig('order', 'order_coupon', 'error_code')).to eq(OrderCoupon.error_codes[:limit_reached])
        expect(parsed_response.dig('order', 'order_coupon', 'discount', 'cents')).to eq(0)
        expect(parsed_response.dig('order', 'discount', 'cents')).to eq(0)
      end
    end

    context 'when reapply different coupon' do
      it 'applies different coupon' do
        order = create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace)
        code1 = create(:coupon, discount_by: 'percentage_discount', workspace: user.workspace, discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100)).code
        code2 = create(:coupon, discount_by: 'percentage_discount', workspace: user.workspace, discount_percentage: 20).code
        calculated_discount = order.subtotal * 0.2

        put apply_coupon_api_v1_storefront_order_url(order), params: { code: code1 }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.dig('order', 'order_coupon')).to be_present
        expect(parsed_response.dig('order', 'order_coupon', 'code')).to eq(code1)
        expect(parsed_response.dig('order', 'order_coupon', 'is_valid')).to be_falsey
        expect(parsed_response.dig('order', 'order_coupon', 'error_code')).to eq(OrderCoupon.error_codes[:minimum_spend_not_reached])
        expect(parsed_response.dig('order', 'order_coupon', 'discount', 'cents')).to eq(0)
        expect(parsed_response.dig('order', 'discount', 'cents')).to eq(0)

        expect do
          put apply_coupon_api_v1_storefront_order_url(order), params: { code: code2 }
        end.not_to(change(OrderCoupon, :count))
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.dig('order', 'order_coupon')).to be_present
        expect(parsed_response.dig('order', 'order_coupon', 'code')).to eq(code2)
        expect(parsed_response.dig('order', 'order_coupon', 'is_valid')).to be_truthy
        expect(parsed_response.dig('order', 'order_coupon', 'error_code')).to eq(OrderCoupon.error_codes[:code_valid])
        expect(parsed_response.dig('order', 'order_coupon', 'discount', 'cents')).to eq(calculated_discount.cents)
        expect(parsed_response.dig('order', 'discount', 'cents')).to eq(calculated_discount.cents)
      end
    end
  end

  path '/api/v1/storefront/orders/{id}/remove_coupon' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('remove coupon from orders') do
      tags 'Storefront Orders'
      consumes 'application/json'
      produces 'application/json'
      # security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, required: false, schema: {
        type: :object,
        properties: {
          code: { type: :string, description: 'Optional' }
        }
      }

      let(:id) { create(:order, :guest_order, :with_line_items, store_id: store.id, workspace: user.workspace).id }
      let(:coupon) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: user.workspace) }
      let!(:coupon_code) { OrderCoupon.create(order_id: id, coupon_id: coupon.id, code: coupon.code) }

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'order_coupon')).to be_nil
          expect(response_body.dig('order', 'discount', 'cents')).to eq(0)
        end
      end

      response(403, 'forbidden') do
        let(:id) { create(:order, :with_line_items, store_id: store.id, workspace: user.workspace).id }

        run_test!
      end
    end
  end
end
