require 'swagger_helper'

RSpec.describe 'api/v1/user/coupons', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:coupon, workspace: user.current_workspace).id }

  path '/api/v1/user/coupons' do
    get('list coupons') do
      tags 'User Coupons'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :scope, in: :query, type: :string, required: false, description: 'Scope, available values: active, expired, scheduled'

      response(200, 'successful') do
        before do
          create_list(:coupon, 3, workspace: user.current_workspace)
        end

        run_test!
      end

    end

    post('create coupons') do
      tags 'User Coupons'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          coupon: {
            type: :object,
            properties: {
              name: { type: :string },
              code: { type: :string },
              redemption_limit: { type: :integer },
              order_types: { 
                type: :array,
                items: { type: :string, enum: Order.order_types.keys }
              },
              start_at: { type: :datetime },
              end_at: { type: :datetime },
              discount_by: { type: :string, enum: Coupon.discount_bies.keys },
              discount_price: { type: :string },
              discount_percentage: { type: :integer },
              minimum_spend: { type: :string },
              maximum_cap: { type: :string },
              coupon_type: { type: :string, enum: Coupon.coupon_types.keys },
              discount_on: { type: :string, enum: Coupon.discount_ons.keys }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { coupon: attributes_for(:coupon) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/coupons/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show coupons') do
      tags 'User Coupons'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update coupons') do
      tags 'User Coupons'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          coupon: {
            type: :object,
            properties: {
              name: { type: :string },
              code: { type: :string },
              redemption_limit: { type: :integer },
              order_types: { 
                type: :array,
                items: { type: :string, enum: Order.order_types.keys }
              },
              start_at: { type: :datetime },
              end_at: { type: :datetime },
              discount_by: { type: :string, enum: Coupon.discount_bies.keys },
              discount_price: { type: :string },
              discount_percentage: { type: :integer },
              minimum_spend: { type: :string },
              maximum_cap: { type: :string },
              coupon_type: { type: :string, enum: Coupon.coupon_types.keys },
              discount_on: { type: :string, enum: Coupon.discount_ons.keys }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { coupon: attributes_for(:coupon) } }      

        run_test!
      end
    end

    delete('delete coupons') do
      tags 'User Coupons'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end

    
  end
end