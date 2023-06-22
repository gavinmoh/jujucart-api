class AddWorkspaceIds < ActiveRecord::Migration[7.0]
  def change
    add_reference :categories, :workspace, foreign_key: true, type: :uuid
    add_reference :coupons, :workspace, foreign_key: true, type: :uuid
    add_reference :accounts, :workspace, foreign_key: true, type: :uuid
    add_reference :inventories, :workspace, foreign_key: true, type: :uuid
    add_reference :inventory_transfers, :workspace, foreign_key: true, type: :uuid
    add_reference :locations, :workspace, foreign_key: true, type: :uuid
    add_reference :orders, :workspace, foreign_key: true, type: :uuid
    add_reference :payments, :workspace, foreign_key: true, type: :uuid
    add_reference :pos_terminals, :workspace, foreign_key: true, type: :uuid
    add_reference :products, :workspace, foreign_key: true, type: :uuid
    add_reference :promotion_bundles, :workspace, foreign_key: true, type: :uuid
    add_reference :sales_statements, :workspace, foreign_key: true, type: :uuid
    add_reference :stores, :workspace, foreign_key: true, type: :uuid
    add_reference :wallets, :workspace, foreign_key: true, type: :uuid
  end
end
