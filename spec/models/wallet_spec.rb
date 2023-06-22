require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:customer).optional }
    it { should have_many(:wallet_transactions).dependent(:destroy) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#set_workspace_id' do
        context 'when customer is present' do
          let(:customer) { create(:customer) }
          let(:wallet) { build(:wallet, customer: customer) }

          it 'sets workspace_id' do
            wallet.workspace = nil
            expect { wallet.valid? }.to change { wallet.workspace_id }.from(nil).to(customer.workspace_id)
          end
        end

        context 'when customer is not present' do
          let(:wallet) { build(:wallet, customer: nil) }

          it 'does not set workspace_id' do
            expect { wallet.valid? }.not_to change { wallet.workspace_id }
          end
        end
      end
    end
  end
end
