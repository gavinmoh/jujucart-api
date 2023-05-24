class Payment < ApplicationRecord
  include ActiveModel::Dirty, AASM
  belongs_to :order, optional: true
  
  enum payment_type: { cash: 'cash', terminal: 'terminal' }

  validates :payment_type, presence: true
  monetize :amount_cents
  
  store_accessor :data, :transaction_reference

  validates :transaction_reference, presence: true, if: -> { self.cash? }

  after_commit :confirm_order, if: -> { saved_change_to_status? and self.success? }, on: [:create, :update]

  aasm column: :status do
    state :pending, initial: true
    state :success, :failed, :cancelled, :unknown

    event :mark_as_success do
      transitions from: [:pending, :unknown], to: :success
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
    def confirm_order
      self.order.confirm!
    end
end
