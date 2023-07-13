require 'rails_helper'

RSpec.describe ProductAddon, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:product).touch.optional }
    it { is_expected.to belong_to(:workspace).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'callbacks' do
    describe '#set_workspace_id' do
      let(:workspace) { create(:workspace) }
      let(:product) { create(:product, workspace: workspace) }
      let(:product_addon) { build(:product_addon, product: product) }

      it 'sets workspace_id' do
        product_addon.valid?
        expect(product_addon.workspace_id).to eq(workspace.id)
      end
    end
  end

  describe 'scopes' do
    describe '.with_store_quantity' do
      let(:store) { create(:store) }
      let(:location) { create(:location, store: store) }
      let!(:product_addon1) { create(:product_addon) }
      let!(:product_addon2) { create(:product_addon) }
      let!(:product_addon_inventory1) { create(:inventory, product: product_addon1, location: location) }
      let!(:product_addon_inventory2) { create(:inventory, product: product_addon2, location: location) }
      let!(:product_addon_inventory_transaction1) { create(:inventory_transaction, inventory: product_addon_inventory1, quantity: 5) }
      let!(:product_addon_inventory_transaction2) { create(:inventory_transaction, inventory: product_addon_inventory2, quantity: 6) }

      it 'returns products with quantity' do
        product_addons = described_class.with_store_quantity(store.id)
        expect(product_addons.first['product_quantity']).to eq(5)
        expect(product_addons.second['product_quantity']).to eq(6)
      end
    end
  end
end
