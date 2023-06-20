class CreateCallbackLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :callback_logs, id: :uuid do |t|
      t.jsonb :request_headers
      t.text :request_body
      t.string :callback_from
      t.datetime :processed_at

      t.timestamps
    end
  end
end
