class WalletTransaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :order, optional: true

  enum transaction_type: { redeem: 'redeem', refund: 'refund', topup: 'topup', referral: 'referral', reward: 'reward' }
  validates :transaction_type, presence: true
  validates :amount, numericality: { other_than: 0 }, allow_blank: false

  after_commit :update_wallet_amount

  private
    def update_wallet_amount
      new_amount = self.wallet.wallet_transactions.sum(:amount)
      self.wallet.update(current_amount: new_amount)
    end
end
