class CreateStores < ActiveRecord::Migration[7.0]
  def change
    create_table :stores, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :logo
      t.boolean :validate_inventory, default: false

      t.timestamps
    end
  end
end
