class RemoveAccountEmailIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :accounts, :email, unique: true
  end
end
