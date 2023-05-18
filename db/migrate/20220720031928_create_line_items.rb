class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: true, foreign_key: true, type: :uuid
      t.integer :quantity, default: 1, null: false
      t.monetize :unit_price
      t.monetize :total_price
      t.string  :name
      t.boolean :product_deleted
      t.jsonb :product_data, default: {}, null: false

      t.timestamps
    end
  end
end
