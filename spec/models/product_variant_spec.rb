require 'rails_helper'

RSpec.describe ProductVariant, type: :model do
  describe 'associations' do
    it { should belong_to(:product).touch.optional }
  end
  
  describe 'validations' do
    it { should validate_uniqueness_of(:product_attributes).scoped_to(:product_id) }

    context 'product_attributes_must_exist' do
      it 'should validate product_attributes_must_exist' do
        product_variant = build(:product_variant, product_attributes: [])
        expect(product_variant.valid?).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      context '#format_product_attributes' do
        let(:product_variant) { build(:product_variant, product_attributes: [{name: 'Colour ', value: 'Red '}]) }

        it 'should format product_attributes' do
          product_variant.valid?
          expect(product_variant.product_attributes).to eq([{"name" => 'Colour', "value" => 'Red'}])
        end
      end
    end
  end

  describe 'scopes' do
    context 'with_store_quantity' do
      let(:store) { create(:store) }
      let(:location) { create(:location, store: store) }
      let!(:product_variant1) { create(:product_variant) }
      let!(:product_variant2) { create(:product_variant) }
      let!(:product_variant_inventory1) { create(:inventory, product: product_variant1, location: location) }
      let!(:product_variant_inventory2) { create(:inventory, product: product_variant2, location: location) }
      let!(:product_variant_inventory_transaction1) { create(:inventory_transaction, inventory: product_variant_inventory1, quantity: 5) }
      let!(:product_variant_inventory_transaction2) { create(:inventory_transaction, inventory: product_variant_inventory2, quantity: 6) }

      it 'should return products with quantity' do
        product_variants = ProductVariant.with_store_quantity(store.id)
        expect(product_variants.first['product_quantity']).to eq(5)
        expect(product_variants.second['product_quantity']).to eq(6)
      end
    end    
  end
end
