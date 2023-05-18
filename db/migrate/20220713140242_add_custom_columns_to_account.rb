class AddCustomColumnsToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :name, :string
    add_column :accounts, :active, :boolean, default: true
    add_column :accounts, :nanoid, :string, index: { unique: true }
    add_column :accounts, :role, :string
    add_column :accounts, :profile_photo, :string
  end
end
