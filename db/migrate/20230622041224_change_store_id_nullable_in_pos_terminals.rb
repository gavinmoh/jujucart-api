class ChangeStoreIdNullableInPosTerminals < ActiveRecord::Migration[7.0]
  def change
    change_column_null :pos_terminals, :store_id, true
  end
end
