class AddStripeCustomerIdToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :stripe_customer_id, :string
  end
end
