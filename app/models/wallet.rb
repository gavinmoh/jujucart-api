class Wallet < ApplicationRecord
  belongs_to :customer

  has_many :wallet_transactions, dependent: :nullify
end
