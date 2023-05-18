class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons, id: :uuid do |t|
      t.string :name
      t.string :code
      t.bigint :redemption_limit, default: 0
      t.string :order_types, array: true, default: []
      t.datetime :start_at
      t.datetime :end_at
      t.string :discount_by
      t.monetize :discount_price
      t.integer :discount_percentage, default: 0
      t.monetize :minimum_spend
      t.monetize :maximum_cap
      t.string :coupon_type
      t.string :discount_on

      t.timestamps
    end
  end
end
