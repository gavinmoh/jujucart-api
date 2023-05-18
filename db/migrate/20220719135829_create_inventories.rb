class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, default: 0, null: false
      t.string :nanoid, index: { unique: true }
      
      t.timestamps
    end
  end
end
