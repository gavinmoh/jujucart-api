class CreateNotificationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_tokens, id: :uuid do |t|
      t.references :recipient, null: true, foreign_key: {to_table: :accounts}, type: :uuid
      t.string :device_uid
      t.string :token
      t.string :device_model
      t.string :device_os
      t.string :app_name
      t.string :app_version

      t.timestamps
    end
  end
end
