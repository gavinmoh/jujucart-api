require 'swagger_helper'

RSpec.describe 'api/v1/user/reports', type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(create(:user)) }

  path '/api/v1/user/reports/overview' do
    get('overview report') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter by from date'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'Filter by to date'
      parameter name: "store_id[]", in: :query, type: :string, required: false, description: 'Filter by store IDs'
      parameter name: :created_by_id, in: :query, type: :string, required: false, description: 'Filter by accounts which created the orders'

      before do
        5.times do
          order = create(:order, completed_at: Faker::Time.between(from: Time.current.beginning_of_month, to: Time.current), created_by_id: create(:user).id)
          create(:customer, created_at: Faker::Time.between(from: Time.current.beginning_of_month, to: Time.current))

          product = create(:product)
          create(:line_item, order: order, product: product)

          order.update!(status: 'completed')

          number_of_payments = (1..2).to_a.sample
          amount_for_each_payment =
            if number_of_payments > 1
              order.total_cents / number_of_payments
            else
              order.total_cents
            end

          number_of_payments.times do
            create(:payment, order: order, amount_cents: amount_for_each_payment, status: 'success', updated_at: order.completed_at)
          end

          order
        end
      end

      response(200, 'successful') do
        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { nil }
        run_test!
      end

      context 'filter by store id' do
        let(:store_id) { create(:store).id }

        it 'should filter by store IDs' do
          Order.where(status: 'completed').limit(2).update_all(store_id: store_id)
          
          get overview_api_v1_user_reports_path, headers: { 'Authorization' => bearer_token_for(create(:user)) }, params: {
            store_id: store_id
          }
          response_body = JSON.parse(response.body)
          expect(response_body['total_transactions']).to eq 2
        end

      end

      context 'filter by created_by_id' do
        let(:created_by_id) { Order.where(status: 'completed').sample.created_by_id }

        it 'should filter by created by ID' do
          get overview_api_v1_user_reports_path, headers: { 'Authorization' => bearer_token_for(create(:user)) }, params: {
            created_by_id: created_by_id
          }

          response_body = JSON.parse(response.body)
          expect(response_body['total_transactions']).to eq 1
        end
      end
    end
  end

  path '/api/v1/user/reports/best_seller_products' do
    get('list best seller products') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "Best seller from date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "Best seller to date"
      parameter name: :store_id, in: :query, type: :string, required: false, description: "Filter products by store"
      parameter name: :metric, in: :query, type: :string, required: false, description: "Set ordering by metric", enum: ['sold_quantity', 'sales_amount']
      parameter name: :category_id, in: :query, type: :string, required: false, description: "Filter products by category"
      parameter name: :limit, in: :query, type: :string, required: false, description: "Limit number of products, default to 10"

      response(200, 'successful') do
        before do
          products = create_list(:product, 5)
          orders = create_list(:order, 3)
          orders.each { create(:line_item, product: products.sample) }
          Order.update_all(completed_at: Time.current, status: :completed)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/reports/best_seller_categories' do
    get('list best seller categories') do
      tags 'User Reports'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "Best seller from date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "Best seller to date"
      parameter name: :store_id, in: :query, type: :string, required: false, description: "Filter orders by store ID"
      parameter name: :metric, in: :query, type: :string, required: false, description: "Set ordering based on metrics", enum: [ 'sold_quantity', 'sales_amount' ]
      parameter name: :limit, in: :query, type: :string, required: false, description: "Limit number of categories, default to 10"

      response(200, 'successful') do
        before do
          categories = create_list(:category, 10)
          products =
            3.times.map do
              create(:product, category: categories.sample)
            end
          orders = create_list(:order, 3)
          orders.each { create(:line_item, product: products.sample) }
          Order.update_all(completed_at: Time.current, status: :completed)
        end

        run_test!
      end
    end
  end
end
