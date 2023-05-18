class CreatePromotionBundleItems < ActiveRecord::Migration[7.0]
  def change
    create_table :promotion_bundle_items, id: :uuid do |t|
      t.references :promotion_bundle, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
