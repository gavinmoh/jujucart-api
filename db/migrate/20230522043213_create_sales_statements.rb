class CreateSalesStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :sales_statements, id: :uuid do |t|
      t.string :nanoid
      t.string :statement_number
      t.date :from_date
      t.date :to_date
      t.monetize :total_sales
      t.monetize :total_delivery_fee
      t.monetize :total_discount
      t.monetize :total_redeemed_coin
      t.monetize :total_gross_profit
      t.string :file

      t.timestamps
    end
  end
end
