class AddVoidedAtAndRefundedAtToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :voided_at, :datetime
    add_column :orders, :refunded_at, :datetime
  end
end
