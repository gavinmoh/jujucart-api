require 'swagger_helper'

RSpec.describe 'api/v1/user/customers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:customer, workspace: user.current_workspace).id }

  path '/api/v1/user/customers' do
    get('list customers') do
      tags 'User Customers'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page,           in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items,          in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :query,          in: :query, type: :string,  required: false, description: "Search by user name or ic number"
      parameter name: :sort_by,        in: :query, type: :string,  required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order,     in: :query, type: :string,  required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"
      parameter name: :active,         in: :query, type: :boolean, required: false, description: "Filter by active or not active"
      parameter name: :filter_date_by, in: :query, type: :string,  required: false, description: "Filter by date, available filter_date_by: 'created_at', 'updated_at'"
      parameter name: :from_date,      in: :query, type: :string,  required: false, description: 'From date'
      parameter name: :to_date,        in: :query, type: :string,  required: false, description: 'To date'

      response(200, 'successful') do
        before do
          create_list(:customer, 3, workspace: user.current_workspace)
        end

        run_test!
      end

    end

    post('create customers') do
      tags 'User Customers'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              phone_number: { type: :string },
              active: { type: :boolean },
              password: { type: :string },
              profile_photo: { type: :string, description: 'Base64 encoded image' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { customer: attributes_for(:customer).slice(:name, :email, :phone_number, :password) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/customers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show customers') do
      tags 'User Customers'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do        
        run_test!
      end
    end

    put('update customers') do
      tags 'User Customers'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              phone_number: { type: :string },
              active: { type: :boolean },
              password: { type: :string },
              profile_photo: { type: :string, description: 'Base64 encoded image' },
              remove_profile_photo: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { customer: attributes_for(:customer).slice(:name, :phone_number, :email) } }      

        run_test!
      end
    end

    # delete('delete customers') do
    #   tags 'User Customers'
    #   security [ { bearerAuth: nil } ]

    #   response(204, 'successful') do
    #     run_test!
    #   end
    # end

    
  end
end