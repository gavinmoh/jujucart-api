class CreateOrderCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :order_coupons, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :coupon, null: true, foreign_key: true, type: :uuid
      t.string :code
      t.monetize :discount
      t.boolean :is_valid, default: true
      t.string :error_code

      t.timestamps
    end
  end
end
