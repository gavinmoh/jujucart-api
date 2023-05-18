class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :scope
      t.string :token
      t.datetime :revoked_at
      t.datetime :expired_at
      t.string :user_agent
      t.string :remote_ip
      t.string :referer

      t.timestamps
    end
  end
end
