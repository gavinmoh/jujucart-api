class AddLineItemsProductDeletedDefaultToFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_default :line_items, :product_deleted, from: nil, to: false
  end
end
