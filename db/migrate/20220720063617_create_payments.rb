class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :order, null: true, foreign_key: true, type: :uuid
      t.string :status
      t.string :payment_type
      t.string :nanoid, index: { unique: true }
      t.monetize :amount
      t.jsonb :data, default: {}, null: false

      t.timestamps
    end
  end
end
