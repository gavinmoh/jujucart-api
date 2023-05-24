class AddUniqueIndexToSessionsToken < ActiveRecord::Migration[7.0]
  def change
    add_index :sessions, :token, unique: true
  end
end
