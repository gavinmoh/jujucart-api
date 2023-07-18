class AddReconciledAtToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :reconciled_at, :datetime
  end
end
