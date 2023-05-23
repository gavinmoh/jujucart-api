class ChangeInventoryFromStoreToLocation < ActiveRecord::Migration[7.0]
  def change
    remove_reference :inventories, :store, null: false, foreign_key: true, type: :uuid
    add_reference :inventories, :location, null: false, foreign_key: true, type: :uuid
  end
end
