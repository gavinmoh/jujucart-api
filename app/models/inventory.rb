class Inventory < ApplicationRecord
  belongs_to :location
  belongs_to :product, class_name: 'BaseProduct'

  has_many :inventory_transactions, dependent: :destroy
end