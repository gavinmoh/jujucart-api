class ChangeOrderNullableInWalletTransactions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :wallet_transactions, :order_id, true
  end
end
