class ChangeAccountsUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :accounts, [:email, :type], unique: true, where: "email IS NOT NULL AND email != ''"
    remove_index :accounts, [:phone_number, :type], unique: true, where: "phone_number IS NOT NULL AND phone_number != ''"

    add_index :accounts, [:email, :type, :workspace_id], unique: true, where: "email IS NOT NULL AND email != ''"
    add_index :accounts, [:phone_number, :type, :workspace_id], unique: true, where: "phone_number IS NOT NULL AND phone_number != ''"
  end
end
