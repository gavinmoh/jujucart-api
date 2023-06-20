class AddTransactionReferenceToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :transaction_reference, :string, index: { unique: true }
  end
end
