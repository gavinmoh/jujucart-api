require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product).optional }
    it { is_expected.to belong_to(:promotion_bundle).optional }
    it { is_expected.to have_many(:line_item_addons).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:line_item_addons).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(1).only_integer }
  end

  describe 'methods' do
    describe '#line_item_addons_price' do
      context 'when line_item_addons is empty' do
        it 'returns 0' do
          line_item = create(:line_item)
          expect(line_item.send(:line_item_addons_price)).to eq(Money.new(0))
        end
      end

      context 'when line_item_addons is not empty' do
        it 'returns sum of line_item_addons prices' do
          line_item = create(:line_item)
          addon1 = create(:line_item_addon, line_item: line_item)
          addon2 = create(:line_item_addon, line_item: line_item)
          expect(line_item.send(:line_item_addons_price)).to eq(addon1.price + addon2.price)
        end
      end

      context 'when line_item_addons has deleted addons' do
        it 'returns sum of line_items_addons prices without deleted addons' do
          line_item = create(:line_item)
          addon1 = create(:line_item_addon, line_item: line_item)
          create(:line_item_addon, line_item: line_item, product_addon_deleted: true)
          expect(line_item.send(:line_item_addons_price)).to eq(addon1.price)
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#assign_unit_price' do
      it 'assigns unit_price' do
        product = create(:product)
        line_item = build(:line_item, product: product)
        line_item.save
        expect(line_item.unit_price).to eq(product.discount_price)
      end

      it 'does not assign unit_price if order is not pending' do
        order = create(:order, status: 'confirmed')
        product = create(:product)
        line_item = build(:line_item, order: order, product: product)
        line_item.unit_price_cents = 0
        line_item.save
        expect(line_item.unit_price_cents).to eq(0)
      end
    end

    describe '#set_total_price' do
      it 'sets total_price' do
        product = create(:product)
        line_item = build(:line_item, product: product)
        line_item.save
        expect(line_item.total_price).to eq(line_item.quantity * product.discount_price)
      end

      it 'does not set total_price if order is not pending' do
        order = create(:order, status: 'confirmed')
        product = create(:product)
        line_item = build(:line_item, order: order, product: product, total_price: nil)
        line_item.save
        expect(line_item.total_price_cents).to eq(0)
      end
    end

    describe '#set_name_from_product' do
      context 'when before_save' do
        it 'sets name' do
          product = create(:product)
          line_item = build(:line_item, product: product)
          line_item.save
          expect(line_item.name).to eq(product.name)
        end

        it 'does not set name if order is not pending' do
          order = create(:order, status: 'confirmed')
          product = create(:product)
          line_item = build(:line_item, order: order, product: product, name: nil)
          line_item.name = nil
          line_item.save
          expect(line_item.name).to be_nil
        end
      end

      context 'when before_create' do
        let(:order) { create(:order, order_type: 'manual') }

        it 'sets name' do
          product = create(:product)
          line_item = build(:line_item, order: order, product: product)
          line_item.save
          expect(line_item.name).to eq(product.name)
        end

        it 'does not set name if product is nil' do
          line_item = build(:line_item, order: order, product: nil)
          line_item.save
          expect(line_item.name).to be_nil
        end

        it 'allows overriding name' do
          product = create(:product)
          line_item = build(:line_item, order: order, product: product, name: 'test')
          line_item.save
          expect(line_item.name).to eq('test')
        end
      end
    end

    describe '#set_unit_price_from_product' do
      let(:order) { create(:order, order_type: 'manual') }

      it 'sets unit_price' do
        product = create(:product)
        line_item = build(:line_item, order: order, product: product)
        line_item.save
        expect(line_item.unit_price).to eq(product.discount_price)
      end

      it 'does not set unit_price if product is nil' do
        line_item = build(:line_item, order: order, product: nil)
        line_item.save
        expect(line_item.unit_price_cents).to eq(0)
      end

      it 'allows overriding unit_price' do
        product = create(:product, price_cents: 1000, discount_price_cents: 0)
        line_item = build(:line_item, order: order, product: product, unit_price_cents: 100)
        line_item.save
        expect(line_item.unit_price_cents).to eq(100)
      end
    end

    describe '#update_order_price' do
      it 'updates order price' do
        order = create(:order)
        order.recalculate_price(true)
        product = create(:product, price_cents: 100, discount_price_cents: 0)
        expect do
          create(:line_item, order: order, product: product, quantity: 2)
        end.to change { order.reload.total_cents }.by(200)
      end

      it 'updates order price if quantity change' do
        order = create(:order)
        order.recalculate_price(true)
        product = create(:product, price_cents: 100, discount_price_cents: 0)
        line_item = create(:line_item, order: order, product: product, quantity: 2)
        expect do
          line_item.update(quantity: 3)
        end.to change { order.reload.total_cents }.by(100)
      end

      it 'does not update order price if order is not pending' do
        order = create(:order, status: 'confirmed')
        product = create(:product, price_cents: 100, discount_price_cents: 0)
        expect do
          create(:line_item, order: order, product: product, quantity: 2)
        end.not_to(change { order.reload.total_cents })
      end
    end
  end

  describe 'scopes' do
    describe '.joins_with_pending_orders' do
      let!(:order1) { create(:order, status: 'pending') }
      let!(:order2) { create(:order, status: 'confirmed') }
      let!(:line_item1) { create(:line_item, order: order1) }
      let!(:line_item2) { create(:line_item, order: order2) }

      it 'returns line_items with pending orders' do
        line_items = described_class.joins_with_pending_orders
        expect(line_items).to include(line_item1)
        expect(line_items).not_to include(line_item2)
      end
    end

    describe '.joins_with_parent_product' do
      let!(:product1) { create(:product) }
      let!(:product2) { create(:product) }
      let!(:product_variant1) { create(:product_variant, product: product1) }
      let!(:product_variant2) { create(:product_variant, product: product2) }
      let!(:line_item1) { create(:line_item, product: product_variant1) }
      let!(:line_item2) { create(:line_item, product: product_variant2) }

      it 'returns line_items with parent product' do
        line_items = described_class.joins_with_parent_product(product1.id)
        expect(line_items).to include(line_item1)
        expect(line_items).not_to include(line_item2)
      end
    end
  end
end
