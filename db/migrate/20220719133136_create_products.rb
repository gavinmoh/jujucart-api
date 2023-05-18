class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name
      t.text :description
      t.boolean :active, default: true
      t.string :featured_photo
      t.references :category, null: true, foreign_key: true, type: :uuid
      t.monetize :price
      t.monetize :discount_price
      t.boolean :is_featured, default: false
      t.string :slug
      t.string :tags, default: [], array: true
      t.boolean :has_no_variant, default: true
      t.boolean :is_cartable, default: true
      t.boolean :is_hidden, default: false
      t.string :sku, index: { unique: true, where: "sku IS NOT NULL AND sku != ''"}
      t.string :nanoid, index: { unique: true }
      t.string :type
      t.jsonb :product_attributes, default: [], null: false, array: true
      t.references :product, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
