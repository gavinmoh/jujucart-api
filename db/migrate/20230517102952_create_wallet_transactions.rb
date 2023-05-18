class CreateWalletTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :wallet_transactions, id: :uuid do |t|
      t.references :wallet, null: false, foreign_key: true, type: :uuid
      t.string :transaction_type
      t.bigint :amount
      t.references :order, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
