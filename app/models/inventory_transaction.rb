class InventoryTransaction < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :inventory

  after_commit :update_inventory_quantity

  validates :quantity, numericality: { other_than: 0, only_integer: true }, allow_nil: false

  private
    def update_inventory_quantity
      return if self.inventory.destroyed?
      new_quantity = self.inventory.inventory_transactions.sum(:quantity)
      self.inventory.update(quantity: new_quantity)
    end
end
