class AddStripeDetailsToWorkspaces < ActiveRecord::Migration[7.0]
  def change
    add_column :workspaces, :stripe_account_id, :string
    add_column :workspaces, :stripe_charges_enabled, :boolean, default: false
    add_column :workspaces, :default_payment_gateway, :string

    add_index :workspaces, :stripe_account_id, unique: true
  end
end
