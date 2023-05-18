FactoryBot.define do
  factory :wallet_transaction do
    wallet_id { create(:wallet).id }
    transaction_type { WalletTransaction.transaction_types.keys.sample }
    amount { Faker::Number.within(range: 10..1000) }
  end
end