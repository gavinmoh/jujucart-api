require 'swagger_helper'

RSpec.describe 'api/v1/user/orders', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:store) { create(:store) }
  let(:id) { create(:order, store_id: store.id).id }

  path '/api/v1/user/orders' do

    get('list orders') do
      tags 'User Orders'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page,           in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items,          in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :query,          in: :query, type: :string,  required: false, description: "Search by order_number"
      parameter name: :status,         in: :query, type: :string,  required: false, description: "Filter by status, available status: #{Order.aasm.states.map(&:name).map(&:to_s).join(', ')}"
      parameter name: :order_type,     in: :query, type: :string, required: false, description: "Filter by order_type, available order_type: #{Order.order_types.keys.join(', ')}"
      parameter name: :scope,          in: :query, type: :string,  required: false, description: "Filter by scope, available scope: ['delivery', 'pickup']"
      parameter name: :flagged,        in: :query, type: :boolean,  required: false, description: "Filter flagged order"
      parameter name: :filter_date_by, in: :query, type: :string,  required: false, description: 'Filter by which date column, e.g. created_at, updated_at'
      parameter name: :from_date,      in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :to_date,        in: :query, type: :string,  required: false, description: 'Filter by date column specified by the params filter_date_by'
      parameter name: :store_id,       in: :query, type: :string, required: false, description: 'Filter by store_id'
      parameter name: :sort_by,        in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order,     in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      

      response(200, 'successful') do
        
        before do
          create_list(:order, 3, store_id: store.id, status: 'confirmed')
        end

        run_test!
      end

    end

    post('create orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              store_id: { type: :string },
              customer_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { order: attributes_for(:order).slice(:store_id, :customer_id) } }

        run_test!
      end
    end
  end

  path '/api/v1/user/orders/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show orders') do
      response(200, 'successful') do
        tags 'User Orders'
        produces 'application/json'
        security [ { bearerAuth: nil } ]

        run_test!
      end
    end

    put('update orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              is_flagged: { type: :boolean },
              flagged_reason: { type: :string },
              unit_number: { type: :string },
              street_address1: { type: :string },
              street_address2: { type: :string },
              postcode: { type: :string },
              city: { type: :string },
              state: { type: :string },
              latitude: { type: :float },
              longitude: { type: :float },
              courier_name: { type: :string },
              tracking_number: { type: :string },
              customer_id: { type: :string, description: 'POS order only' },
              redeemed_coin: { type: :integer, description: 'POS order only' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:id) { create(:order, store_id: store.id, order_type: 'delivery', status: 'confirmed').id }
        let(:data) { { order: attributes_for(:order).slice(:courier_name, :tracking_number) } }

        run_test!
      end
    end

    delete('delete orders') do
      response(204, 'successful') do
        tags 'User Orders'
        security [ { bearerAuth: nil } ]

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
      security [ { bearerAuth: nil } ]

      let(:user) { create(:user, role: 'cashier') }
      let(:id) { create(:order, store_id: store.id, order_type: 'pos', status: 'pending').id }

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

  path '/api/v1/user/orders/{id}/complete' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('complete orders') do
      tags 'User Orders'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]    

      parameter name: :data, in: :body, schema: {
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
        let(:data) { { order: { transaction_reference: '12345' } } }

        context 'when order is pending_payment' do
          let(:user) { create(:user, role: 'cashier') }
          let(:id) { create(:order, order_type: 'pos', store_id: store.id, status: 'pending_payment', customer_id: nil).id }

          before do
            create(:assigned_store, user_id: user.id, store_id: store.id)
          end

          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body.dig('order', 'status')).to eq('completed')
          end
        end

        context 'when order is packed' do
          let(:user) { create(:user, role: 'admin')}
          let(:id) { create(:order, order_type: 'pickup', status: 'packed').id }
          
          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body.dig('order', 'status')).to eq('completed')
          end
        end

      end
    end    
  end

  path '/api/v1/user/orders/{id}/pack' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('pack orders') do
      tags 'User Orders'
      produces 'application/json'
      security [ { bearerAuth: nil } ]
      
      response(200, 'successful') do
        let(:user) { create(:user, role: 'admin')}
        let(:id) { create(:order, order_type: 'delivery', status: 'confirmed').id }

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
      security [ { bearerAuth: nil } ]

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
        let(:user) { create(:user, role: 'admin')}
        let(:id) { create(:order, status: 'packed').id }
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
      security [ { bearerAuth: nil } ]
      
      response(200, 'successful') do
        let(:order) { create(:order, status: 'packed') }
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
end