class CreateLineItemAddons < ActiveRecord::Migration[7.0]
  def change
    create_table :line_item_addons, id: :uuid do |t|
      t.references :line_item, null: false, foreign_key: true, type: :uuid
      t.references :product_addon, null: false, foreign_key: { to_table: :products }, type: :uuid
      t.monetize :price
      t.string :product_addon_name
      t.boolean :product_addon_deleted, default: false

      t.timestamps
    end
  end
end
