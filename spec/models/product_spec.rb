require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to have_many(:product_variants).dependent(:destroy) }
    it { is_expected.to have_many(:product_addons).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:product_variants).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:product_addons).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'callbacks' do
    describe '#set_slug' do
      let(:product) { build(:product, name: 'Product Name') }

      it 'set slug' do
        expect do
          product.save!
        end.to change(product, :slug).from(nil).to('product-name')
      end

      context 'when slug is already present' do
        let(:workspace) { create(:workspace) }
        let(:product) { create(:product, workspace: workspace) }
        let(:new_product) { create(:product, workspace: workspace, name: product.name) }

        it { expect(new_product.slug).not_to eq(product.slug) }
      end
    end

    describe '#update_line_items_name' do
      let(:product) { create(:product, name: 'Product Name') }
      let(:line_item) { create(:line_item, product: product) }

      it 'updates line items name' do
        expect do
          product.update(name: 'New Product Name')
        end.to (change { line_item.reload.name }).from('Product Name').to('New Product Name')
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_product) { create(:product, active: true) }
      let!(:inactive_product) { create(:product, active: false) }

      it 'returns active products' do
        products = Product.active
        expect(products).to include(active_product)
        expect(products).not_to include(inactive_product)
      end
    end

    describe '.query' do
      let(:query) { SecureRandom.alphanumeric(10) }
      let!(:product1) { create(:product, name: query) }
      let!(:product2) { create(:product) }

      it 'returns products' do
        products = Product.query(query)
        expect(products).to include(product1)
        expect(products).not_to include(product2)
      end
    end

    describe '.with_store_quantity' do
      let(:store) { create(:store) }
      let(:location) { create(:location, store: store) }
      let!(:product1) { create(:product) }
      let!(:product_variant1) { create(:product_variant, product: product1, product_attributes: [{ name: 'Colour', value: 'Red' }]) }
      let!(:product_variant2) { create(:product_variant, product: product1, product_attributes: [{ name: 'Colour', value: 'Blue' }]) }
      let!(:product_inventory1) { create(:inventory, product: product1, location: location) }
      let!(:product_inventory_transaction1) { create(:inventory_transaction, inventory: product_inventory1, quantity: 10) }
      let!(:product_variant_inventory1) { create(:inventory, product: product_variant1, location: location) }
      let!(:product_variant_inventory2) { create(:inventory, product: product_variant2, location: location) }
      let!(:product_variant_inventory_transaction1) { create(:inventory_transaction, inventory: product_variant_inventory1, quantity: 5) }
      let!(:product_variant_inventory_transaction2) { create(:inventory_transaction, inventory: product_variant_inventory2, quantity: 6) }
      let!(:product_addon) { create(:product_addon, product: product1) }
      let!(:product_addon_inventory) { create(:inventory, product: product_addon, location: location) }
      let!(:product_addon_inventory_transaction) { create(:inventory_transaction, inventory: product_addon_inventory, quantity: 7) }

      it 'returns products with quantity' do
        products = described_class.with_store_quantity(store.id)
        expect(products.first['product_quantity']).to eq(10)
        expect(products.first['variant_quantity']).to eq(11)
        expect(products.first['addon_quantity']).to eq(7)
      end
    end
  end
end
