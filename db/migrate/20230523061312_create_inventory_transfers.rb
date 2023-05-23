class CreateInventoryTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_transfers, id: :uuid do |t|
      t.references :transfer_from_location, null: true, foreign_key: { to_table: :locations }, type: :uuid
      t.references :transfer_to_location, null: true, foreign_key: { to_table: :locations }, type: :uuid
      t.string :nanoid, index: { unique: true }
      t.string :remark
      t.string :acceptance_remark
      t.string :status
      t.datetime :transferred_at
      t.datetime :accepted_at
      t.datetime :cancelled_at
      t.datetime :reverted_at
      t.references :transferred_by, null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :accepted_by,    null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :cancelled_by,   null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :reverted_by,    null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :created_by,     null: true, foreign_key: { to_table: :accounts }, type: :uuid

      t.timestamps
    end
  end
end
