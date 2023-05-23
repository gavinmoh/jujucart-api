class CreateInventoryTransferItems < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_transfer_items, id: :uuid do |t|
      t.references :inventory_transfer, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.references :product, null: true, foreign_key: true, type: :uuid
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
