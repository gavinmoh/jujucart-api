class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.string :order_type
      t.string :nanoid, index: { unique: true }
      t.references :customer, null: true, foreign_key: {to_table: :accounts}, type: :uuid
      t.string :status
      t.monetize :total
      t.monetize :subtotal
      t.monetize :delivery_fee
      t.monetize :discount
      t.boolean :is_flagged
      t.string :flagged_reason
      t.references :store, null: true, foreign_key: true, type: :uuid
      t.string :unit_number
      t.string :street_address1
      t.string :street_address2
      t.string :postcode
      t.string :city
      t.string :state
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :courier_name
      t.string :tracking_number
      t.bigint :reward_coin, default: 0
      t.integer :redeemed_coin, default: 0
      t.monetize :redeemed_coin_value
      t.datetime :pending_payment_at
      t.datetime :confirmed_at
      t.datetime :packed_at
      t.datetime :shipped_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.datetime :failed_at
      t.references :created_by, null: true, foreign_key: {to_table: :accounts}, type: :uuid

      t.timestamps
    end
  end
end
