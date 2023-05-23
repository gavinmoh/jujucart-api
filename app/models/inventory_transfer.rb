class InventoryTransfer < ApplicationRecord
  include AASM
  belongs_to :transfer_from_location, optional: true, class_name: 'Location'
  belongs_to :transfer_to_location, optional: true, class_name: 'Location'
  belongs_to :transferred_by, optional: true, class_name: 'Account'
  belongs_to :accepted_by, optional: true, class_name: 'Account'
  belongs_to :cancelled_by, optional: true, class_name: 'Account'
  belongs_to :reverted_by, optional: true, class_name: 'Account'
  belongs_to :created_by, optional: true, class_name: 'Account'

  has_many :inventory_transfer_items, dependent: :destroy
  has_many :inventory_transactions, dependent: :destroy

  accepts_nested_attributes_for :inventory_transfer_items, allow_destroy: true
  
  validate :either_transfer_from_location_or_transfer_to_location_must_present

  after_commit :create_transfer_out_inventory_transactions, on: :update, if: -> { saved_change_to_status? && self.transfer_from_location && self.transferred? }
  after_commit :create_transfer_in_inventory_transactions, on: :update, if: -> { saved_change_to_status? && self.transfer_to_location && self.accepted? }
  after_commit :destroy_inventory_transactions, on: :update, if: -> { saved_change_to_status? && self.reverted? }

  enum status: { pending: 'pending', transferred: 'transferred', accepted: 'accepted', cancelled: 'cancelled', reverted: 'reverted' }

  aasm column: :status, enum: true, whiny_transitions: false, timestamps: true do
    state :pending, initial: true
    state :transferred, :accepted, :cancelled, :reverted

    event :transfer do
      transitions from: :pending, to: :transferred, guard: [:transferred_by_present?]
    end

    event :accept do
      transitions from: :transferred, to: :accepted, guard: [:accepted_by_present?]
      transitions from: :pending, to: :accepted, guard: [:accepted_by_present?, :transfer_from_location_is_nil?]
    end

    event :cancel do
      transitions from: :pending, to: :cancelled, guard: [:cancelled_by_present?]
    end

    event :revert do
      transitions from: :accepted, to: :reverted, guard: [:reverted_by_present?]
    end
  end

  private
    def either_transfer_from_location_or_transfer_to_location_must_present
      return unless self.transfer_from_location.nil? && self.transfer_to_location.nil?
      errors.add(:transfer_from_location, "or transfer_to_location must present")
    end

    def create_transfer_out_inventory_transactions
      ActiveRecord::Base.transaction do
        self.inventory_transfer_items.includes(:product).each do |item|
          inventory = Inventory.find_or_create_by!(location_id: self.transfer_from_location.id, product_id: item.product_id)
          InventoryTransaction.find_or_create_by!(inventory_id: inventory.id, 
                                                 quantity: item.quantity * -1,
                                                 inventory_transfer_id: self.id)
        end
      end
    end

    def create_transfer_in_inventory_transactions
      ActiveRecord::Base.transaction do
        self.inventory_transfer_items.includes(:product).each do |item|
          inventory = Inventory.find_or_create_by!(location_id: self.transfer_to_location.id, product_id: item.product_id)
          InventoryTransaction.find_or_create_by!(inventory_id: inventory.id, 
                                                  quantity: item.quantity,
                                                  inventory_transfer_id: self.id)
        end
      end
    end

    def destroy_inventory_transactions
      ActiveRecord::Base.transaction do
        self.inventory_transactions.find_each { |transaction| transaction.destroy! }
      end
    end

    def transferred_by_present?
      if self.transferred_by.nil?
        errors.add(:transferred_by, "must present")
        return false
      else
        return true
      end
    end

    def accepted_by_present?
      if self.accepted_by.nil?
        errors.add(:accepted_by, "must present")
        return false
      else
        return true
      end
    end

    def cancelled_by_present?
      if self.cancelled_by.nil?
        errors.add(:cancelled_by, "must present")
        return false
      else
        return true
      end
    end

    def reverted_by_present?
      if self.reverted_by.nil?
        errors.add(:reverted_by, "must present")
        return false
      else
        return true
      end
    end

    def transfer_from_location_is_nil?
      if self.transfer_from_location.present?
        errors.add(:transfer_from_location, "must not present")
        return false
      else
        return true
      end
    end
end
