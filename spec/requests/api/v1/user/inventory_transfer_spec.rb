require 'swagger_helper'

RSpec.describe 'api/v1/user/inventory_transfers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:inventory_transfer, :with_inventory_transfer_items).id }

  path '/api/v1/user/inventory_transfers' do
    get('list inventory transfers') do
      tags 'User Inventory Transfers'
      security [ { bearerAuth: nil } ]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :transfer_from_location_id, in: :query, type: :string, required: false, description: 'Transfer From Location ID'
      parameter name: :transfer_to_location_id, in: :query, type: :string, required: false, description: 'Transfer To Location ID'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Status'

      response(200, 'successful') do
        before do
          create_list(:inventory_transfer, 3)
        end

        run_test!
      end

    end

    post('create inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transfer: {
            type: :object,
            properties: {
              transfer_from_location_id: { type: :string },
              transfer_to_location_id: { type: :string },
              remark: { type: :string },
              inventory_transfer_items_attributes: {
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
        let(:data) { { inventory_transfer: attributes_for(:inventory_transfer)
                                              .slice(:transfer_from_location_id, 
                                                     :transfer_to_location_id,
                                                     :remark)
                                              .merge(inventory_transfer_items_attributes: [attributes_for(:inventory_transfer_item).slice(:product_id, :quantity)]) } }

        run_test!
      end
    end

  end

  path '/api/v1/user/inventory_transfers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transfer: {
            type: :object,
            properties: {
              transfer_from_location_id: { type: :string },
              transfer_to_location_id: { type: :string },
              remark: { type: :string },
              inventory_transfer_items_attributes: {
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
        let(:data) { { inventory_transfer: attributes_for(:inventory_transfer).slice(:remark).merge(inventory_transfer_items_attributes: [attributes_for(:inventory_transfer_item).slice(:product_id, :quantity)]) } }      

        run_test!
      end
    end

    delete('delete inventory transfers') do
      tags 'User Inventory Transfers'
      security [ { bearerAuth: nil } ]

      response(204, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/inventory_transfers/{id}/transfer' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('transfer inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['inventory_transfer']['status']).to eq('transferred')
          expect(parsed_response['inventory_transfer']['transferred_at']).to be_present
        end
      end
    end
  end

  path '/api/v1/user/inventory_transfers/{id}/cancel' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('cancel inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['inventory_transfer']['status']).to eq('cancelled')
          expect(parsed_response['inventory_transfer']['cancelled_at']).to be_present
        end
      end
    end
  end

  path '/api/v1/user/inventory_transfers/{id}/accept' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('accept inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      consumes 'application/json'
      security [ { bearerAuth: nil } ]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          inventory_transfer: {
            type: :object,
            properties: {
              acceptance_remark: { type: :string }
            }
          }
        }
      }

      before do
        inventory_transfer = InventoryTransfer.find(id)
        inventory_transfer.transferred_by = create(:user)
        inventory_transfer.transfer!
      end

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { inventory_transfer: attributes_for(:inventory_transfer).slice(:acceptance_remark) } }
        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['inventory_transfer']['status']).to eq('accepted')
          expect(parsed_response['inventory_transfer']['accepted_at']).to be_present
        end
      end
    end
  end

  path '/api/v1/user/inventory_transfers/{id}/revert' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('revert inventory transfers') do
      tags 'User Inventory Transfers'
      produces 'application/json'
      security [ { bearerAuth: nil } ]

      before do
        inventory_transfer = InventoryTransfer.find(id)
        inventory_transfer.transferred_by = create(:user)
        inventory_transfer.transfer!
        inventory_transfer.accepted_by = create(:user)
        inventory_transfer.accept!
      end

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['inventory_transfer']['status']).to eq('reverted')
          expect(parsed_response['inventory_transfer']['reverted_at']).to be_present
        end
      end
    end
  end



  

end