class CreateOrderAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :order_attachments, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.string :file
      t.string :name

      t.timestamps
    end
  end
end
