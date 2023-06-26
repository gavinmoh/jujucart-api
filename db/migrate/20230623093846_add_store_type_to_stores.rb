class AddStoreTypeToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :store_type, :string
    add_column :stores, :hostname, :string

    add_index :stores, :hostname, unique: true, where: "hostname IS NOT NULL and hostname != ''"
  end
end
