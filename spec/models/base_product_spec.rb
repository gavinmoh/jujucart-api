require 'rails_helper'

RSpec.describe BaseProduct, type: :model do
  describe 'associations' do
    it { should have_many(:line_items).dependent(:nullify) }
    it { should have_many(:inventories).dependent(:destroy) }
    it { should have_many(:promotion_bundle_items).dependent(:destroy) }
    it { should have_many(:inventory_transfer_items).dependent(:nullify) }    
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:sku).allow_nil.allow_blank }
  end

  describe 'callbacks' do
    context 'after_commit' do
      context '#update_line_items' do
        let(:product) { create(:product, name: 'Product Name') }
        let(:product_variant) { create(:product_variant, product: product, name: nil)}
        let!(:line_item1) { create(:line_item, product: product) }
        let!(:line_item2) { create(:line_item, product: product_variant) }

        it 'should update line items' do
          expect do
            product.update(name: 'New Product Name')
          end.to (change { line_item1.reload.name }).from('Product Name').to('New Product Name')
             .and (change { line_item2.reload.name }).from('Product Name').to('New Product Name')
        end
      end
    end

    context 'before_destroy' do
      context '#mark_line_items_product_deleted' do
        let(:product) { create(:product) }
        let(:product_variant) { create(:product_variant, product: product, name: nil)}
        let!(:line_item1) { create(:line_item, product_id: product.id) }
        let!(:line_item2) { create(:line_item, product_id: product_variant.id) }

        it 'should mark line items product deleted' do
          expect do
            product_variant.destroy
          end.to (change { line_item2.reload.product_deleted }).from(false).to(true)

          expect do
            product.destroy
          end.to (change { line_item1.reload.product_deleted }).from(false).to(true)
        end
      end
    end
  end

  describe 'scopes' do
    context 'with_sold_quantity_and_sales_amount_cents' do
      before do
        3.times do |n|
          product = create(:product, price: (n+1).to_s, discount_price_cents: 0)
          line_item = create(:line_item, product: product, quantity: n+1)
          line_item.order.update_columns(completed_at: Time.current, status: :completed)
        end
      end

      it 'should return sold quantity and sales_amount_cents' do
        products = BaseProduct.with_sold_quantity_and_sales_amount_cents
                              .order('sold_quantity ASC')
        products.each.with_index do |product, n|
          expect(product['sold_quantity']).to eq(n+1)
          expect(product['sales_amount_cents']).to eq(((n+1)*100) * (n+1))
        end
      end
    end
  end
end
