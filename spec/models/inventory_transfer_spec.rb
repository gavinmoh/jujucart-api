require 'rails_helper'

RSpec.describe InventoryTransfer, type: :model do
  describe 'associations' do
    subject { build(:inventory_transfer) }
    it { should belong_to(:workspace) }
    it { should belong_to(:transfer_from_location).optional }
    it { should belong_to(:transfer_to_location).optional }
    it { should belong_to(:transferred_by).optional }
    it { should belong_to(:accepted_by).optional } 
    it { should belong_to(:cancelled_by).optional }
    it { should belong_to(:reverted_by).optional }
    it { should have_many(:inventory_transfer_items).dependent(:destroy) }
    it { should have_many(:inventory_transactions).dependent(:destroy) }

    it { should accept_nested_attributes_for(:inventory_transfer_items).allow_destroy(true) }
  end

  describe 'validations' do
    context 'validate either_transfer_from_location_or_transfer_to_location_must_present' do
      it 'should validate either_transfer_from_location_or_transfer_to_location_must_present' do
        inventory_transfer = build(:inventory_transfer, transfer_from_location: nil, transfer_to_location: nil)
        expect(inventory_transfer.valid?).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    context 'after_commit' do
      describe '#create_transfer_out_inventory_transactions' do
        let(:inventory_transfer) { create(:inventory_transfer, :with_inventory_transfer_items) }
  
        it 'should create inventory_transactions' do
          inventory_transfer.transferred_by = create(:user)
          expect do
            inventory_transfer.transfer!
          end.to change(InventoryTransaction, :count).by(2)
        end
      end

      describe '#create_transfer_in_inventory_transactions' do
        let(:inventory_transfer) { create(:inventory_transfer, :with_inventory_transfer_items) }
  
        it 'should create inventory_transactions' do
          inventory_transfer.transferred_by = create(:user)
          inventory_transfer.transfer!
          inventory_transfer.accepted_by = create(:user)
          
          expect do
            inventory_transfer.accept!
          end.to change(InventoryTransaction, :count).by(2)
        end
      end

      describe '#destroy_inventory_transactions' do
        let(:inventory_transfer) { create(:inventory_transfer, :with_inventory_transfer_items) }

        it 'should destroy inventory_transactions on revert' do
          inventory_transfer.transferred_by = create(:user)
          inventory_transfer.transfer!
          inventory_transfer.accepted_by = create(:user)
          inventory_transfer.accept!
          inventory_transfer.reverted_by = create(:user)
          
          expect do
            inventory_transfer.revert!  
          end.to change(InventoryTransaction, :count).by(-4)
        end
      end
    end
  end

  describe 'aasm' do
    describe 'states' do
      subject { create(:inventory_transfer, :with_inventory_transfer_items) }
      it { is_expected.to have_state(:pending) }
      context 'transfer' do
        before { subject.transferred_by = create(:user) }
        it { is_expected.to transition_from(:pending).to(:transferred).on_event(:transfer) }
      end
      context 'cancel' do
        before { subject.cancelled_by = create(:user) }
        it { is_expected.to transition_from(:pending).to(:cancelled).on_event(:cancel) }
      end
      context 'accept' do
        context 'when transfer_from is nil' do
          before do
            subject.accepted_by = create(:user)
            subject.transfer_from_location = nil
          end
          it { is_expected.to transition_from(:pending).to(:accepted).on_event(:accept) }
        end
      end
      context 'revert' do
        before do
          subject.status = 'accepted'
          subject.reverted_by = create(:user)
        end
        it { is_expected.to transition_from(:accepted).to(:reverted).on_event(:revert) }
      end
    end
  end
end
