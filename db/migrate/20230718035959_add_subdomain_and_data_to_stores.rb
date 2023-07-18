class AddSubdomainAndDataToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :subdomain, :string
    add_column :stores, :nanoid, :string
    add_column :stores, :data, :jsonb, default: {}

    add_index :stores, :subdomain, unique: true
    add_index :stores, :nanoid, unique: true
  end
end
