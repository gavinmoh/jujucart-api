class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :recipient, null: false, foreign_key: {to_table: :accounts}, type: :uuid
      t.string :subject
      t.text :message
      t.references :record, null: true, type: :uuid, polymorphic: true
      t.timestamp :read_at
      t.string :notification_type

      t.timestamps
    end
    add_index :notifications, :read_at
    add_index :notifications, :notification_type
  end
end
