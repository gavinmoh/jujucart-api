class Payment < ApplicationRecord
  include ActiveModel::Dirty, AASM
  belongs_to :order, optional: true
  
  enum payment_type: { cash: 'cash', terminal: 'terminal' }

  validates :payment_type, presence: true
  monetize :amount_cents
  
  store_accessor :data, :transaction_reference

  validates :transaction_reference, presence: true, if: -> { self.cash? }

  aasm column: :status do
    state :pending, initial: true
    state :success, :failed, :cancelled, :unknown

    event :mark_as_success do
      transitions from: [:pending, :unknown], to: :success, 
                  after: :update_order_status
    end

    event :mark_as_failed do
      transitions from: [:pending, :unknown], to: :failed
    end

    event :mark_as_cancelled do
      transitions from: [:pending, :unknown], to: :cancelled
    end

    event :mark_as_unknown do
      transitions from: [:pending], to: :unknown
    end
  end

  private
    def update_order_status
      self.order.confirm!
    end
end
