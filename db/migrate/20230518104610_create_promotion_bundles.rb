class CreatePromotionBundles < ActiveRecord::Migration[7.0]
  def change
    create_table :promotion_bundles, id: :uuid do |t|
      t.string :name
      t.string :discount_by
      t.monetize :discount_price
      t.integer :discount_percentage, default: 0
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
