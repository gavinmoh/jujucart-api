class InventoryTransferItem < ApplicationRecord
  belongs_to :inventory_transfer
  belongs_to :product, optional: true, class_name: 'BaseProduct'

  before_validation :set_name, on: :create

  validate :product_must_exist, on: :create
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }

  private
    def set_name
      return if self.product.nil?
      self.name = self.product.name
    end

    def product_must_exist
      errors.add(:product, "does not exist") if self.product.nil?
    end
end
