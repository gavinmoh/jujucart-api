class Payment < ApplicationRecord
  include ActiveModel::Dirty, AASM
  belongs_to :order, optional: true
  
  enum payment_type: { cash: 'cash', terminal: 'terminal' }

  validates :payment_type, presence: true
  monetize :amount_cents
  
  store_accessor :data, :revenue_monster, :payment_method, :terminal_id

  validates :transaction_reference, presence: true, if: -> { self.cash? }
  validates :transaction_reference, uniqueness: true, allow_blank: true

  after_commit :confirm_order, if: -> { saved_change_to_status? and self.success? }, on: [:create, :update]
  after_commit :refund_order, if: -> { saved_change_to_status? and self.refunded? }, on: [:create, :update]

  aasm column: :status do
    state :pending, initial: true
    state :success, :failed, :cancelled, :unknown, :refunded

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

    event :refund do
      transitions from: [:success], to: :refunded
    end
  end

  private
    def confirm_order
      if self.order.may_complete?
        self.order.complete!
      else
        self.order.confirm!
      end
    end

    def refund_order
      self.order.refund!
    end
end
