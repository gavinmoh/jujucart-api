require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product).optional }
    it { should belong_to(:promotion_bundle).optional }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1).only_integer }
  end

  describe 'callbacks' do
    context 'before_save' do
      context '#assign_unit_price' do
        it 'should assign unit_price' do
          product = create(:product)
          line_item = build(:line_item, product: product)
          line_item.save
          expect(line_item.unit_price).to eq(product.discount_price)
        end

        it 'should not assign unit_price if order is not pending' do
          order = create(:order, status: 'confirmed')
          product = create(:product)
          line_item = build(:line_item, order: order, product: product)
          line_item.unit_price_cents = 0
          line_item.save
          expect(line_item.unit_price_cents).to eq(0)
        end
      end

      context '#set_total_price' do
        it 'should set total_price' do
          product = create(:product)
          line_item = build(:line_item, product: product)
          line_item.save
          expect(line_item.total_price).to eq(line_item.quantity * product.discount_price)
        end

        it 'should not set total_price if order is not pending' do
          order = create(:order, status: 'confirmed')
          product = create(:product)
          line_item = build(:line_item, order: order, product: product, total_price: nil)
          line_item.save
          expect(line_item.total_price_cents).to eq(0)
        end
      end

      context '#set_name_from_product' do
        it 'should set name' do
          product = create(:product)
          line_item = build(:line_item, product: product)
          line_item.save
          expect(line_item.name).to eq(product.name)
        end

        it 'should not set name if order is not pending' do
          order = create(:order, status: 'confirmed')
          product = create(:product)
          line_item = build(:line_item, order: order, product: product, name: nil)
          line_item.name = nil
          line_item.save
          expect(line_item.name).to be_nil
        end
      end
    end

    context '#before_create' do
      context '#set_unit_price_from_product' do
        let(:order) { create(:order, order_type: 'manual') }

        it 'should set unit_price' do
          product = create(:product)
          line_item = build(:line_item, order: order, product: product)
          line_item.save
          expect(line_item.unit_price).to eq(product.discount_price)
        end

        it 'should not set unit_price if product is nil' do
          line_item = build(:line_item, order: order, product: nil)
          line_item.save
          expect(line_item.unit_price_cents).to eq(0)
        end

        it 'should allow overriding unit_price' do
          product = create(:product, price_cents: 1000, discount_price_cents: 0)
          line_item = build(:line_item, order: order, product: product, unit_price_cents: 100)
          line_item.save
          expect(line_item.unit_price_cents).to eq(100)
        end
      end

      context '#set_name_from_product' do
        let(:order) { create(:order, order_type: 'manual') }

        it 'should set name' do
          product = create(:product)
          line_item = build(:line_item, order: order, product: product)
          line_item.save
          expect(line_item.name).to eq(product.name)
        end

        it 'should not set name if product is nil' do
          line_item = build(:line_item, order: order, product: nil)
          line_item.save
          expect(line_item.name).to be_nil
        end

        it 'should allow overriding name' do
          product = create(:product)
          line_item = build(:line_item, order: order, product: product, name: 'test')
          line_item.save
          expect(line_item.name).to eq('test')
        end        
      end
    end

    context 'after_commit' do
      context '#update_order_price' do
        it 'should update order price' do
          order = create(:order)
          order.recalculate_price(true)
          product = create(:product, price_cents: 100, discount_price_cents: 0)
          expect do
            create(:line_item, order: order, product: product, quantity: 2)
          end.to change { order.reload.total_cents }.by(200)
        end

        it 'should update order price if quantity change' do
          order = create(:order)
          order.recalculate_price(true)
          product = create(:product, price_cents: 100, discount_price_cents: 0)
          line_item = create(:line_item, order: order, product: product, quantity: 2)
          expect do
            line_item.update(quantity: 3)
          end.to change { order.reload.total_cents }.by(100)
        end

        it 'should not update order price if order is not pending' do
          order = create(:order, status: 'confirmed')
          product = create(:product, price_cents: 100, discount_price_cents: 0)
          expect do
            create(:line_item, order: order, product: product, quantity: 2)
          end.not_to(change { order.reload.total_cents })
        end
      end
    end
  end

  describe 'scopes' do
    context '#joins_with_pending_orders' do
      let!(:order1) { create(:order, status: 'pending') }
      let!(:order2) { create(:order, status: 'confirmed') }
      let!(:line_item1) { create(:line_item, order: order1) }
      let!(:line_item2) { create(:line_item, order: order2) }

      it 'should return line_items with pending orders' do
        line_items = LineItem.joins_with_pending_orders
        expect(line_items).to include(line_item1)
        expect(line_items).to_not include(line_item2)
      end
    end

    context '#joins_with_parent_product' do
      let!(:product1) { create(:product) }
      let!(:product2) { create(:product) }
      let!(:product_variant1) { create(:product_variant, product: product1) }
      let!(:product_variant2) { create(:product_variant, product: product2) }
      let!(:line_item1) { create(:line_item, product: product_variant1) }
      let!(:line_item2) { create(:line_item, product: product_variant2) }

      it 'should return line_items with parent product' do
        line_items = LineItem.joins_with_parent_product(product1.id)
        expect(line_items).to include(line_item1)
        expect(line_items).to_not include(line_item2)
      end
    end
  end
end
