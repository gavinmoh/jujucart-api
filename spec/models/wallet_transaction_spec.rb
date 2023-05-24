require 'rails_helper'

RSpec.describe WalletTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:wallet) }
    it { should belong_to(:order).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:transaction_type) }
    it { should validate_numericality_of(:amount).is_other_than(0) }
    it { should define_enum_for(:transaction_type).with_values({ redeem: 'redeem', refund: 'refund', topup: 'topup', referral: 'referral', reward: 'reward' }).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    describe 'after_commit' do
      it 'update wallet amount' do
        wallet = create(:wallet)
        transaction = create(:wallet_transaction, wallet: wallet, amount: 100)
        create(:wallet_transaction, wallet: wallet, amount: 200)
        wallet.reload
        expect(wallet.current_amount).to eq(300)

        transaction.destroy
        wallet.reload
        expect(wallet.current_amount).to eq(200)
      end
    end
  end
end
