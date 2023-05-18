require 'swagger_helper'

RSpec.describe 'api/v1/user/reports', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:customer) { create(:customer) }
  let(:store) { create(:store) }
  let(:Authorization) { bearer_token_for(user) }
  let(:from_date) { Date.today - 1.month }
  let(:to_date) { Date.today }

  path '/api/v1/user/reports/revenue' do
    get('total revenue') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :to_date,   in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store'
      parameter name: :order_type, in: :query, type: :string, required: false, description: "Filter by order type, available types are #{Order.order_types.keys.join(', ')}"

      response(200, 'successful') do
        before do
          create_list(:order, 5, status: 'confirmed',
                                 customer_id: customer.id,
                                 store_id: store.id,
                                 pending_payment_at: Faker::Date.between(from: from_date, to: to_date).beginning_of_day)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/reports/total_paid_order' do
    get('total paid order') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :to_date,   in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store'
      parameter name: :order_type, in: :query, type: :string, required: false, description: "Filter by order type, available types are #{Order.order_types.keys.join(', ')}"

      response(200, 'successful') do
        before do
          create_list(:order, 5, status: 'confirmed',
                                 customer_id: customer.id,
                                 store_id: store.id,
                                 pending_payment_at: Faker::Date.between(from: from_date, to: to_date).beginning_of_day)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/reports/total_checkout' do
    get('total checkout order') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :to_date,   in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store'
      parameter name: :order_type, in: :query, type: :string, required: false, description: "Filter by order type, available types are #{Order.order_types.keys.join(', ')}"

      response(200, 'successful') do
        before do
          create_list(:order, 5, status: 'confirmed',
                                 customer_id: customer.id,
                                 store_id: store.id,
                                 pending_payment_at: Faker::Date.between(from: from_date, to: to_date).beginning_of_day)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/reports/total_abandoned' do
    get('total abandoned order') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :to_date,   in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store'
      parameter name: :order_type, in: :query, type: :string, required: false, description: "Filter by order type, available types are #{Order.order_types.keys.join(', ')}"

      response(200, 'successful') do
        before do
          create_list(:order, 5, status: 'confirmed',
                                 customer_id: customer.id,
                                 store_id: store.id,
                                 pending_payment_at: Faker::Date.between(from: from_date, to: to_date).beginning_of_day)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/reports/total_order' do
    get('total order') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :to_date,   in: :query, type: :string, required: false, description: 'Filter by date range, both from_date and to_date must exists'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store'
      parameter name: :order_type, in: :query, type: :string, required: false, description: "Filter by order type, available types are #{Order.order_types.keys.join(', ')}"

      response(200, 'successful') do
        before do
          create_list(:order, 5, status: 'confirmed',
                                 customer_id: customer.id,
                                 store_id: store.id,
                                 pending_payment_at: Faker::Date.between(from: from_date, to: to_date).beginning_of_day)
        end

        run_test!
      end
    end
  end
end