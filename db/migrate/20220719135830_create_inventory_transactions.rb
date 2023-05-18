class CreateInventoryTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_transactions, id: :uuid do |t|
      t.references :order, null: true, foreign_key: true, type: :uuid
      t.references :inventory, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, default: 0, null: false
      t.text :description
      t.string :nanoid, index: { unique: true }
      t.monetize :price
      t.monetize :unit_price

      t.timestamps
    end
  end
end
