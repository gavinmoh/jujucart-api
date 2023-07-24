require 'swagger_helper'

RSpec.describe 'api/v1/storefront/products', type: :request do
  # change the create(:user) to respective user model name
  let(:store) { create(:store, store_type: 'online') }
  let(:product) { create(:product, workspace: store.workspace) }
  let(:slug) { product.slug }
  let(:mock_request) { instance_double(ActionDispatch::Request) }

  before do
    allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
  end

  path '/api/v1/storefront/products' do
    get('list products') do
      tags 'Storefront Products'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :category, in: :query, type: :string, required: false, description: 'Filter by category slug'
      parameter name: :query, in: :query, type: :string, required: false, description: "Search by product name"
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        before do
          3.times do
            product = create(:product, workspace: store.workspace)
            variant = create(:product_variant, product: product)
            variant_inventory = create(:inventory, product: variant, location: store.location)
            create(:inventory_transaction, inventory: variant_inventory)
            addon = create(:product_addon, product: product)
            addon_inventory = create(:inventory, product: addon, location: store.location)
            create(:inventory_transaction, inventory: addon_inventory)
          end
          create(:product, workspace: store.workspace)
          product_without_variant = create(:product, workspace: store.workspace)
          product_without_variant_inventory = create(:inventory, product: product_without_variant, location: store.location)
          create(:inventory_transaction, inventory: product_without_variant_inventory)
          hidden_product = create(:product, workspace: store.workspace, is_hidden: true)
          hidden_product_inventory = create(:inventory, product: hidden_product, location: store.location)
          create(:inventory_transaction, inventory: hidden_product_inventory)
          non_active_product = create(:product, workspace: store.workspace, active: false)
          non_active_product_inventory = create(:inventory, product: non_active_product, location: store.location)
          create(:inventory_transaction, inventory: non_active_product_inventory)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['products'].count).to eq(4)
        end
      end

      context 'when filter by category slug' do
        it 'returns products with the specified category' do
          category1 = create(:category, workspace: store.workspace)
          category2 = create(:category, workspace: store.workspace)
          product1 = create(:product, workspace: store.workspace, category: category1)
          product1_inventory = create(:inventory, product: product1, location: store.location)
          create(:inventory_transaction, inventory: product1_inventory)
          product2 = create(:product, workspace: store.workspace, category: category2)
          product2_inventory = create(:inventory, product: product2, location: store.location)
          create(:inventory_transaction, inventory: product2_inventory)

          get '/api/v1/storefront/products', params: { category: category1.slug }
          response_body = JSON.parse(response.body)
          expect(response_body['products'].count).to eq(1)
          expect(response_body['products'][0]['id']).to eq(product1.id)
        end
      end

      context 'when filter by tag' do
        it 'returns products with the specified tag' do
          tag1 = 'tag1'
          tag2 = 'tag2'
          product1 = create(:product, workspace: store.workspace, tags: [tag1])
          product1_inventory = create(:inventory, product: product1, location: store.location)
          create(:inventory_transaction, inventory: product1_inventory)
          product2 = create(:product, workspace: store.workspace, tags: [tag2])
          product2_inventory = create(:inventory, product: product2, location: store.location)
          create(:inventory_transaction, inventory: product2_inventory)

          get '/api/v1/storefront/products', params: { tag: tag1 }
          response_body = JSON.parse(response.body)
          expect(response_body['products'].count).to eq(1)
          expect(response_body['products'][0]['id']).to eq(product1.id)
        end
      end
    end
  end

  path '/api/v1/storefront/products/all' do
    get('list all products slug') do
      tags 'Storefront Products'
      produces 'application/json'

      response(200, 'successful') do
        before do
          3.times do
            product = create(:product, workspace: store.workspace)
            variant = create(:product_variant, product: product)
            variant_inventory = create(:inventory, product: variant, location: store.location)
            create(:inventory_transaction, inventory: variant_inventory)
          end
        end

        run_test!
      end
    end
  end

  path '/api/v1/storefront/products/{slug}' do
    parameter name: 'slug', in: :path, type: :string, description: 'slug'

    get('show products') do
      tags 'Storefront Products'
      produces 'application/json'

      before do
        variant1 = create(:product_variant, product_id: product.id, product_attributes: [{ name: 'Color', value: 'Red' }])
        inventory1 = Inventory.find_or_create_by(product_id: variant1.id, location_id: store.location.id, workspace: store.workspace)
        create(:inventory_transaction, inventory_id: inventory1.id)
        variant2 = create(:product_variant, product_id: product.id, product_attributes: [{ name: 'Color', value: 'Blue' }])
        inventory2 = Inventory.find_or_create_by(product_id: variant2.id, location_id: store.location.id, workspace: store.workspace)
        create(:inventory_transaction, inventory_id: inventory2.id)
        variant3 = create(:product_variant, product_id: product.id, product_attributes: [{ name: 'Color', value: 'Green' }])
        inventory3 = Inventory.find_or_create_by(product_id: variant3.id, location_id: store.location.id, workspace: store.workspace)
        create(:inventory_transaction, inventory_id: inventory3.id)
        addon = create(:product_addon, workspace: store.workspace)
        inventory4 = Inventory.find_or_create_by(product_id: addon.id, location_id: store.location.id, workspace: store.workspace)
        create(:inventory_transaction, inventory_id: inventory4.id)
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
