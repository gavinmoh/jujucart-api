class CreatePosTerminals < ActiveRecord::Migration[7.0]
  def change
    create_table :pos_terminals, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :terminal_id
      t.string :label

      t.timestamps
    end
  end
end
