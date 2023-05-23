require 'rails_helper'

RSpec.describe InventoryTransferItem, type: :model do
  describe 'associations' do
    it { should belong_to(:inventory_transfer) }
    context 'belongs_to :product' do
      subject { create(:inventory_transfer_item) }
      it { should belong_to(:product).optional }
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
    
    context 'validate product_must_exist' do
      it 'should validate product_must_exist' do
        inventory_transfer_item = build(:inventory_transfer_item, product: nil)
        expect(inventory_transfer_item.valid?).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      describe '#set_name' do
        let(:product) { create(:product) }
        let(:inventory_transfer_item) { build(:inventory_transfer_item, product: product) }

        it 'sets the name' do
          inventory_transfer_item.valid?
          expect(inventory_transfer_item.name).to eq(product.name)
        end
      end
    end
    
  end



end
