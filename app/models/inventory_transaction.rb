class InventoryTransaction < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :inventory

  after_commit :update_inventory_quantity

  private
    def update_inventory_quantity
      new_quantity = self.inventory.inventory_transactions.sum(:quantity)
      self.inventory.update(quantity: new_quantity)
    end
end
