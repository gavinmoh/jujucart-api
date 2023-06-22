class CreateWorkspaces < ActiveRecord::Migration[7.0]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.string :name
      t.jsonb :settings, null: false, default: {}
      t.string :logo
      t.string :subdomain, index: { unique: true }
      t.references :owner, null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :created_by, null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :nanoid, index: { unique: true }

      t.timestamps
    end
  end
end
