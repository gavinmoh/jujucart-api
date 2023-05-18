class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets, id: :uuid do |t|
      t.references :customer, null: false, foreign_key: {to_table: :accounts}, type: :uuid
      t.bigint :current_amount, null: false, default: 0

      t.timestamps
    end
  end
end
