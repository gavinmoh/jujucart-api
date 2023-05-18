class CreateAssignedStores < ActiveRecord::Migration[7.0]
  def change
    create_table :assigned_stores, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :store, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
