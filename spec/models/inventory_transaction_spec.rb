require 'rails_helper'

RSpec.describe InventoryTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:order).optional }
    it { should belong_to(:inventory) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_other_than(0).only_integer }
  end

  describe 'callbacks' do
    describe 'after_commit' do
      it 'update inventory quantity' do
        inventory = create(:inventory)
        transaction = create(:inventory_transaction, inventory: inventory, quantity: 10)
        create(:inventory_transaction, inventory: inventory, quantity: 20)
        inventory.reload
        expect(inventory.quantity).to eq(30)

        transaction.destroy
        inventory.reload
        expect(inventory.quantity).to eq(20)
      end
    end
  end
end
