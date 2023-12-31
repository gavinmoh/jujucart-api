require 'swagger_helper'

RSpec.describe 'api/v1/user/orders', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:store) { create(:store, workspace: user.current_workspace) }
  let(:id) { create(:order, store_id: store.id, workspace: user.current_workspace).id }

  path '/api/v1/user/orders' do
    get('list orders') do
      tags 'User Orders'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page,            in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items,           in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :query,           in: :query, type: :string,  required: false, description: "Search by order_number"
      parameter name: :status,          in: :query, type: :string,  required: false, description: "Filter by status, available status: #{Order.aasm.states.map(&:name).map(&:to_s).join(', ')}"
      parameter name: :customer_id,     in: :query, type: :string,  required: false, description: 'Filter by customer_id'
      parameter name: :order_type,      in: :query, type: :string, required: false, description: "Filter by order_type, available order_type: #{Order.order_types.keys.join(', ')}"
      parameter name: :scope,           in: :query, type: :string, required: false, description: "Filter by scope, available scope: ['delivery', 'pickup']"
      parameter name: :is_flagged,      in: :query, type: :boolean, required: false, description: "Filter flagged order"
      parameter name: :filter_date_by,  in: :query, type: :string,  required: false, description: 'Filter by which date column, e.g. created_at, updated_at'
      parameter name: :from_date,       in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :to_date,         in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :store_id,        in: :query, type: :string, required: false, description: 'Filter by store_id'
      parameter name: :sort_by,         in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order,      in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      parameter name: :skip_pagination, in: :query, type: :boolean, required: false, description: 'Skip pagination'
      parameter name: 'ids[]',          in: :query, type: :array, required: false, description: 'Filter by ids'

      response(200, 'successful') do
        before do
          create_list(:order, 3, store_id: store.id, status: 'confirmed', workspace: user.current_workspace)
        end

        run_test!
      end
    end

    post('create orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              store_id: { type: :string },
              customer_id: { type: :string },
              order_type: { type: :string, enum: %w[manual pos] },
              is_flagged: { type: :boolean },
              flagged_reason: { type: :string },
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
              courier_name: { type: :string },
              tracking_number: { type: :string },
              line_items_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    name: { type: :string },
                    product_id: { type: :string },
                    quantity: { type: :integer },
                    unit_price: { type: :string },
                    _destroy: { type: :boolean }
                  }
                }
              },
              order_attachments_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    file: { type: :string },
                    name: { type: :string },
                    _destroy: { type: :boolean }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        context 'when order_type is pos' do
          let(:data) { { order: attributes_for(:order).slice(:store_id, :customer_id) } }

          after do |example|
            content = example.metadata[:response][:content] || {}
            example_spec = {
              "application/json" => {
                examples: {
                  "when order_type is pos" => {
                    value: JSON.parse(response.body, symbolize_names: true)
                  }
                }
              }
            }
            example.metadata[:response][:content] = content.deep_merge(example_spec)
          end

          run_test!
        end

        context 'when order_type is manual' do
          let(:data) do
            {
              order: attributes_for(:order, order_type: 'manual')
                .slice(:store_id, :order_type)
                .merge(line_items_attributes: [attributes_for(:line_item)])
                .merge(order_attachments_attributes: [attributes_for(:order_attachment)])
            }
          end

          after do |example|
            content = example.metadata[:response][:content] || {}
            example_spec = {
              "application/json" => {
                examples: {
                  "when order_type is manual" => {
                    value: JSON.parse(response.body, symbolize_names: true)
                  }
                }
              }
            }
            example.metadata[:response][:content] = content.deep_merge(example_spec)
          end

          run_test! do |response|
            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:order][:line_items].size).to eq(1)
          end
        end
      end
    end
  end

  path '/api/v1/user/orders/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show orders') do
      response(200, 'successful') do
        tags 'User Orders'
        produces 'application/json'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end

    put('update orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              is_flagged: { type: :boolean },
              flagged_reason: { type: :string },
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
              courier_name: { type: :string },
              tracking_number: { type: :string },
              customer_id: { type: :string, description: 'POS order only' },
              redeemed_coin: { type: :integer, description: 'POS order only' },
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

      response(200, 'successful', save_request_example: :data) do
        let(:id) { create(:order, store_id: store.id, order_type: 'delivery', status: 'confirmed', workspace: user.current_workspace).id }
        let(:data) { { order: attributes_for(:order).slice(:courier_name, :tracking_number).merge(order_attachments_attributes: [attributes_for(:order_attachment).slice(:name, :file)]) } }

        run_test!
      end
    end

    delete('delete orders') do
      response(204, 'successful') do
        tags 'User Orders'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}/checkout' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('checkout orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending', workspace: user.current_workspace).id }

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              customer_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:data) { { order: { customer_id: create(:customer).id } } }

        before do
          create(:assigned_store, user_id: user.id, store_id: store.id)
          create_list(:line_item, 2, order_id: id)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}/confirm' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('confirm orders') do
      tags 'User Orders'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:user) { create(:user, role: 'cashier') }
        let(:id) { create(:order, :with_line_items, order_type: 'manual', store_id: store.id, status: 'pending', customer_id: nil, workspace: user.current_workspace).id }

        before do
          create(:assigned_store, user_id: user.id, store_id: store.id)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'status')).to eq('confirmed')
        end
      end
    end
  end

  path '/api/v1/user/orders/{id}/complete' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('complete orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, required: false, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              transaction_reference: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:user) { create(:user, role: 'cashier') }
        let(:id) { create(:order, order_type: 'pos', store_id: store.id, status: 'pending_payment', customer_id: nil, workspace: user.current_workspace).id }
        # let(:data) { { order: { transaction_reference: '12345' } } }

        before do
          create(:assigned_store, user_id: user.id, store_id: store.id)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'status')).to eq('completed')
        end
      end

      context 'when order is packed' do
        let(:user) { create(:user, role: 'admin') }
        let(:id) { create(:order, workspace: user.current_workspace, order_type: 'pickup', status: 'packed').id }

        it 'completes order' do
          put complete_api_v1_user_order_url(id: id), headers: { Authorization: bearer_token_for(user) }
          expect(response).to have_http_status(:ok)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig('order', 'status')).to eq('completed')
        end
      end
    end
  end

  path '/api/v1/user/orders/{id}/void' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('void orders') do
      tags 'User Orders'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:user) { create(:user) }
        let(:id) { create(:order, workspace: user.current_workspace, order_type: 'pos', store_id: store.id, status: 'pending_payment', customer_id: nil).id }

        before do
          create(:assigned_store, user_id: user.id, store_id: store.id)
          payment = create(:payment, order_id: id)
          payment.mark_as_success!
          payment.order.complete!
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'status')).to eq('voided')
          expect(response_body.dig('order', 'voided_at')).to be_present
        end
      end
    end
  end

  path '/api/v1/user/orders/{id}/pack' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('pack orders') do
      tags 'User Orders'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:user) { create(:user, role: 'admin') }
        let(:id) { create(:order, order_type: 'delivery', status: 'confirmed', workspace: user.current_workspace).id }

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}/ship' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('ship orders') do
      tags 'User Orders'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              courier_name: { type: :string },
              tracking_number: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:user) { create(:user, role: 'admin') }
        let(:id) { create(:order, status: 'packed', workspace: user.current_workspace).id }
        let(:data) { { order: { courier_name: 'POS Laju', tracking_number: 'EM12345678' } } }

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}/versions' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('order versions') do
      tags 'User Orders'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:order) { create(:order, status: 'packed', workspace: user.current_workspace) }
        let(:id) { order.id }

        before do
          PaperTrail.enabled = true
          order.update(attributes_for(:order))
          order.update(attributes_for(:order))
          order.update(attributes_for(:order))
          PaperTrail.enabled = false
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}/apply_coupon' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('apply coupon to orders') do
      tags 'User Orders'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          code: { type: :string }
        },
        required: ['code']
      }

      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending', workspace: user.current_workspace).id }

      before do
        create(:assigned_store, user_id: user.id, store_id: store.id)
        create_list(:line_item, 2, order_id: id)
      end

      response(200, 'successful', save_request_example: :data) do
        let(:code) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: user.current_workspace).code }
        let(:data) { { code: code } }

        run_test! do |response|
          order = Order.find(id)
          response_body = JSON.parse(response.body)
          expected_discount = order.subtotal * 0.1
          expect(response_body.dig('order', 'order_coupon')).to be_present
          expect(response_body.dig('order', 'order_coupon', 'code')).to eq(code)
          expect(response_body.dig('order', 'order_coupon', 'discount', 'cents')).to eq(expected_discount.cents)
          expect(response_body.dig('order', 'discount', 'cents')).to eq(expected_discount.cents)
        end
      end

      response(404, 'not_found') do
        let(:data) { { code: SecureRandom.alphanumeric(10) } }
        run_test!
      end
    end

    context 'when minimum spend is not met' do
      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending', workspace: user.current_workspace).id }

      it 'does not apply discount' do
        create(:assigned_store, user_id: user.id, store_id: store.id)
        create_list(:line_item, 2, order_id: id)
        order = Order.find(id)
        code = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100), workspace: user.current_workspace).code

        put apply_coupon_api_v1_user_order_url(id: id), params: { code: code }, headers: { Authorization: bearer_token_for(user) }
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
      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending', workspace: user.current_workspace).id }

      it 'does not apply discount' do
        create(:assigned_store, user_id: user.id, store_id: store.id)
        create_list(:line_item, 2, order_id: id)
        coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, redemption_limit: 1, workspace: user.current_workspace)
        code = coupon.code
        create(:order_coupon, order_id: create(:order, workspace: user.current_workspace, status: 'confirmed').id, coupon_id: coupon.id, error_code: 'code_valid', is_valid: true)

        put apply_coupon_api_v1_user_order_url(id: id), params: { code: code }, headers: { Authorization: bearer_token_for(user) }
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
      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, workspace: user.current_workspace, store_id: store.id, order_type: 'pos', status: 'pending').id }

      it 'applies different coupon' do
        create(:assigned_store, user_id: user.id, store_id: store.id)
        create_list(:line_item, 2, order_id: id)
        order = Order.find(id)
        code1 = create(:coupon, discount_by: 'percentage_discount', workspace: user.current_workspace, discount_percentage: 10, minimum_spend: order.subtotal + Money.new(100)).code
        code2 = create(:coupon, discount_by: 'percentage_discount', workspace: user.current_workspace, discount_percentage: 20).code
        calculated_discount = order.subtotal * 0.2

        put apply_coupon_api_v1_user_order_url(id: id), params: { code: code1 }, headers: { Authorization: bearer_token_for(user) }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.dig('order', 'order_coupon')).to be_present
        expect(parsed_response.dig('order', 'order_coupon', 'code')).to eq(code1)
        expect(parsed_response.dig('order', 'order_coupon', 'is_valid')).to be_falsey
        expect(parsed_response.dig('order', 'order_coupon', 'error_code')).to eq(OrderCoupon.error_codes[:minimum_spend_not_reached])
        expect(parsed_response.dig('order', 'order_coupon', 'discount', 'cents')).to eq(0)
        expect(parsed_response.dig('order', 'discount', 'cents')).to eq(0)

        expect do
          put apply_coupon_api_v1_user_order_url(id: id), params: { code: code2 }, headers: { Authorization: bearer_token_for(user) }
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

  path '/api/v1/user/orders/{id}/remove_coupon' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('remove coupon from orders') do
      tags 'User Orders'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, required: false, schema: {
        type: :object,
        properties: {
          code: { type: :string, description: 'Optional' }
        }
      }

      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending', workspace: user.current_workspace).id }
      let(:code) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: user.current_workspace).code }

      response(200, 'successful', save_request_example: :data) do
        before do
          create(:assigned_store, user_id: user.id, store_id: store.id)
          create_list(:line_item, 2, order_id: id)
          coupon = Coupon.find_by(code: code)
          OrderCoupon.create(order_id: id, coupon_id: coupon.id, code: coupon.code)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body.dig('order', 'order_coupon')).to be_nil
          expect(response_body.dig('order', 'discount', 'cents')).to eq(0)
        end
      end
    end
  end

  path '/api/v1/user/orders/bulk_confirm' do
    put('bulk confirm orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :array, items: { type: :string } }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'manual', status: 'pending', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'manual', status: 'pending', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('confirmed')
          expect(Order.find(order2.id).status).to eq('confirmed')
        end
      end

      response(422, 'unprocessable entity') do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'manual', status: 'completed', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'manual', status: 'pending', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('completed')
          expect(Order.find(order2.id).status).to eq('pending')
        end
      end
    end
  end

  path '/api/v1/user/orders/bulk_pack' do
    put('bulk pack orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :array, items: { type: :string } }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, order_type: 'delivery', status: 'confirmed', workspace: user.current_workspace) }
        let(:order2) { create(:order, order_type: 'delivery', status: 'confirmed', workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('packed')
          expect(Order.find(order2.id).status).to eq('packed')
        end
      end

      response(422, 'unprocessable entity') do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, order_type: 'delivery', status: 'completed', workspace: user.current_workspace) }
        let(:order2) { create(:order, order_type: 'delivery', status: 'confirmed', workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('completed')
          expect(Order.find(order2.id).status).to eq('confirmed')
        end
      end
    end
  end

  path '/api/v1/user/orders/bulk_complete' do
    put('bulk complete orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :array, items: { type: :string } }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'delivery', status: 'shipped', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'delivery', status: 'shipped', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('completed')
          expect(Order.find(order2.id).status).to eq('completed')
        end
      end

      response(422, 'unprocessable entity') do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'delivery', status: 'packed', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'delivery', status: 'pending', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('packed')
          expect(Order.find(order2.id).status).to eq('pending')
        end
      end
    end
  end

  path '/api/v1/user/orders/bulk_void' do
    put('bulk void orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :array, items: { type: :string } }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'pos', status: 'completed', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'pos', status: 'completed', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('voided')
          expect(Order.find(order2.id).status).to eq('voided')
        end
      end

      response(422, 'unprocessable entity') do
        let(:user) { create(:user, role: 'admin') }
        let(:order1) { create(:order, :with_line_items, order_type: 'pos', status: 'completed', workspace: user.current_workspace) }
        let(:order2) { create(:order, :with_line_items, order_type: 'pos', status: 'pending', customer: nil, workspace: user.current_workspace) }
        let(:data) { { ids: [order1.id, order2.id] } }

        run_test! do
          expect(Order.find(order1.id).status).to eq('completed')
          expect(Order.find(order2.id).status).to eq('pending')
        end
      end
    end
  end
end
