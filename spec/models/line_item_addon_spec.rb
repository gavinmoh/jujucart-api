require 'rails_helper'

RSpec.describe LineItemAddon, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:line_item).touch(true) }
    it { is_expected.to belong_to(:product_addon) }
  end

  describe 'monetize' do
    it { is_expected.to monetize(:price_cents) }
  end

  describe 'validations' do
    subject { create(:line_item_addon) }

    it { is_expected.to validate_uniqueness_of(:product_addon_id).scoped_to(:line_item_id).case_insensitive.on(:create) }

    describe '#product_addon_must_belongs_to_line_item_product' do
      let(:line_item) { create(:line_item, product: product) }
      let(:product_addon) { create(:product_addon, product: product) }
      let(:line_item_addon) { build(:line_item_addon, line_item: line_item, product_addon: product_addon) }
      let(:line_item_addon_with_different_addon) { build(:line_item_addon, line_item: line_item, product_addon: create(:product_addon)) }

      context 'when line_item product is a Product' do
        let(:product) { create(:product) }

        it { expect(line_item_addon).to be_valid }
        it { expect(line_item_addon_with_different_addon).to be_invalid }
      end

      context 'when line_item product is a ProductVariant' do
        let(:product) { create(:product_variant) }

        it { expect(line_item.product_id).not_to eq(product_addon.product_id) }
        it { expect(line_item_addon).to be_valid }
        it { expect(line_item_addon_with_different_addon).to be_invalid }
      end
    end
  end

  describe 'callbacks' do
    describe '#set_name_and_price' do
      let(:line_item_addon) { build(:line_item_addon) }

      it 'sets name and price' do
        expect { line_item_addon.valid? }.to change(line_item_addon, :product_addon_name)
          .from(nil).to(line_item_addon.product_addon.name)
          .and change(line_item_addon, :price_cents).from(0).to(line_item_addon.product_addon_price.cents)
      end
    end

    describe '#update_line_item_price' do
      let(:line_item) { create(:line_item) }
      let(:line_item_addon) { build(:line_item_addon, line_item: line_item) }

      it 'updates line_item price' do
        line_item_addon.valid?
        expected_price = (line_item.unit_price + line_item_addon.price) * line_item.quantity
        expect do
          line_item_addon.save!
          line_item.reload
        end.to change(line_item, :total_price_cents).to(expected_price.cents)
      end
    end
  end
end
