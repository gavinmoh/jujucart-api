class CreateUserWorkspaces < ActiveRecord::Migration[7.0]
  def change
    create_table :user_workspaces, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.boolean :admin, default: false
      t.string :role

      t.timestamps
    end
  end
end
