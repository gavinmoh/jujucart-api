require 'swagger_helper'

RSpec.describe 'api/v1/user/products', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:product, workspace: user.current_workspace).id }

  path '/api/v1/user/products' do
    get('list products') do
      tags 'User Products'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :category_id, in: :query, type: :string, required: false, description: 'Filter by category_id'
      parameter name: :store_id, in: :query, type: :string, required: false, description: 'Filter by store_id'
      parameter name: :query, in: :query, type: :string, required: false, description: "Search by product name"
      parameter name: :sku, in: :query, type: :string, required: false, description: "Search by product sku"
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by which column/attribute'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: "Default to descending, available sort_order: 'asc', 'desc'"

      response(200, 'successful') do
        let(:store) { create(:store) }
        let(:store_id) { store.id }
        before do
          3.times do
            product = create(:product, workspace: user.current_workspace)
            variant = create(:product_variant, product_id: product.id)
            product_inventory = create(:inventory, product_id: product.id, location_id: store.location.id, workspace: user.current_workspace)
            create(:inventory_transaction, inventory_id: product_inventory.id)
            variant_inventory = create(:inventory, product_id: variant.id, location_id: store.location.id, workspace: user.current_workspace)
            create(:inventory_transaction, inventory_id: variant_inventory.id)
            addon = create(:product_addon, product_id: product.id)
            addon_inventory = create(:inventory, product_id: addon.id, location_id: store.location.id, workspace: user.current_workspace)
            create(:inventory_transaction, inventory_id: addon_inventory.id)
          end
        end

        run_test!
      end
    end

    post('create products') do
      tags 'User Products'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              active: { type: :string },
              featured_photo: { type: :string },
              remove_featured_photo: { type: :boolean },
              category_id: { type: :string },
              price: { type: :string },
              discount_price: { type: :string },
              is_featured: { type: :boolean },
              has_no_variant: { type: :boolean },
              is_cartable: { type: :boolean },
              is_hidden: { type: :boolean },
              sku: { type: :string },
              tags: {
                type: :array,
                items: { type: :string }
              },
              product_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    values: { type: :string }
                  }
                }
              },
              product_variants_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    description: { type: :string },
                    featured_photo: { type: :string },
                    remove_featured_photo: { type: :boolean },
                    sku: { type: :string },
                    price: { type: :string },
                    discount_price: { type: :string },
                    active: { type: :boolean },
                    product_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          value: { type: :string }
                        }
                      }
                    }
                  }
                }
              },
              product_addons_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    description: { type: :string },
                    featured_photo: { type: :string },
                    remove_featured_photo: { type: :boolean },
                    sku: { type: :string },
                    price: { type: :string },
                    discount_price: { type: :string },
                    active: { type: :boolean }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { product: attributes_for(:product)
            .merge(product_variants_attributes: [attributes_for(:product_variant)],
                   product_addons_attributes: [attributes_for(:product_addon)]) }
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['product']['name']).to eq(data[:product][:name])
          expect(response_body['product']['product_variants'].count).to eq(1)
          expect(response_body['product']['product_addons'].count).to eq(1)
        end
      end
    end
  end

  path '/api/v1/user/products/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :store_id, in: :query, type: :string, required: false, description: 'Display product inventory for store_id'

    get('show products') do
      tags 'User Products'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      let(:store) { create(:store, workspace: user.current_workspace) }
      let(:store_id) { store.id }

      response(200, 'successful') do
        before do
          variant1 = create(:product_variant, product_id: id, product_attributes: [{ name: 'Color', value: 'Red' }])
          inventory1 = Inventory.find_or_create_by(product_id: variant1.id, location_id: store.location.id, workspace: user.current_workspace)
          create(:inventory_transaction, inventory_id: inventory1.id)
          variant2 = create(:product_variant, product_id: id, product_attributes: [{ name: 'Color', value: 'Blue' }])
          inventory2 = Inventory.find_or_create_by(product_id: variant2.id, location_id: store.location.id, workspace: user.current_workspace)
          create(:inventory_transaction, inventory_id: inventory2.id)
          variant3 = create(:product_variant, product_id: id, product_attributes: [{ name: 'Color', value: 'Green' }])
          inventory3 = Inventory.find_or_create_by(product_id: variant3.id, location_id: store.location.id, workspace: user.current_workspace)
          create(:inventory_transaction, inventory_id: inventory3.id)
          addon = create(:product_addon, product_id: id)
          inventory4 = Inventory.find_or_create_by(product_id: addon.id, location_id: store.location.id, workspace: user.current_workspace)
          create(:inventory_transaction, inventory_id: inventory4.id)
        end

        run_test!
      end
    end

    put('update products') do
      tags 'User Products'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              active: { type: :string },
              featured_photo: { type: :string },
              remove_featured_photo: { type: :boolean },
              category_id: { type: :string },
              price: { type: :string },
              discount_price: { type: :string },
              is_featured: { type: :boolean },
              has_no_variant: { type: :boolean },
              is_cartable: { type: :boolean },
              is_hidden: { type: :boolean },
              sku: { type: :string },
              tags: {
                type: :array,
                items: { type: :string }
              },
              product_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    values: { type: :string }
                  }
                }
              },
              product_variants_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    name: { type: :string },
                    description: { type: :string },
                    featured_photo: { type: :string },
                    remove_featured_photo: { type: :boolean },
                    sku: { type: :string },
                    price: { type: :string },
                    discount_price: { type: :string },
                    _destroy: { type: :boolean },
                    product_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          value: { type: :string }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { product: attributes_for(:product) } }

        run_test!
      end
    end

    delete('delete products') do
      tags 'User Products'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/products/import' do
    post('import products from csv') do
      tags 'User Products'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              file: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:data) { { product: { file: "data:application/csv;base64,(#{Base64.encode64(File.read(File.join(Rails.root.join('spec/fixtures/products.csv'))))})" } } }

        run_test!
      end
    end
  end

  path '/api/v1/user/products/import_template' do
    get('download import template') do
      tags 'User Products'
      produces 'text/csv'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'text/csv' => {
              example: response.body
            }
          }
        end

        run_test!
      end
    end
  end
end
