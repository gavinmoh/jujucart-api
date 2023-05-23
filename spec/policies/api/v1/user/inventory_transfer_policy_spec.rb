require 'rails_helper'

RSpec.describe Api::V1::User::InventoryTransferPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:inventory_transfer) { create(:inventory_transfer) }

  subject { described_class }

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  permissions :show?, :create?, :accept?, :transfer?, :cancel?, :revert? do
    it 'grants access' do
      expect(subject).to permit(user, inventory_transfer)
      expect(subject).to permit(user, create(:inventory_transfer))
    end
  end

  permissions :update?, :destroy? do
    it 'grant access' do
      expect(subject).to permit(user, inventory_transfer)
      expect(subject).to permit(user, create(:inventory_transfer))
    end

    it 'denies access if record not pending' do
      inventory_transfer.update(status: 'accepted')
      expect(subject).not_to permit(user, inventory_transfer)
    end
  end
end
