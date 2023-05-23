class AddInventoryTransferToInventoryTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :inventory_transactions, :inventory_transfer, null: true, foreign_key: true, type: :uuid
  end
end
