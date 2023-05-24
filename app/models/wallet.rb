class Wallet < ApplicationRecord
  belongs_to :customer, optional: true

  has_many :wallet_transactions, dependent: :destroy
end
