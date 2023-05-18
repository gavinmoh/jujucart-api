class AddDiscountToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_monetize :line_items, :discount
    add_reference :line_items, :promotion_bundle, null: true, foreign_key: true, type: :uuid
  end
end
