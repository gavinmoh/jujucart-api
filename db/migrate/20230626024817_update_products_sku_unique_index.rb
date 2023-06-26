class UpdateProductsSkuUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :products, :sku, unique: true, where: "sku IS NOT NULL AND sku != ''"
    add_index :products, %i[sku workspace_id], unique: true, where: "sku IS NOT NULL AND sku != ''"
  end
end
