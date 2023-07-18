class Payment < ApplicationRecord
  include AASM
  include ActiveModel::Dirty
  belongs_to :workspace
  belongs_to :order, optional: true

  enum payment_type: { cash: 'cash', terminal: 'terminal', online: 'online' }

  validates :payment_type, presence: true
  monetize :amount_cents

  store_accessor :data, [
    :revenue_monster, :payment_method, :terminal_id, :billplz, :service_provider,
    :created_source
  ]

  # validates :transaction_reference, presence: true, if: -> { self.cash? }
  validates :transaction_reference, uniqueness: true, allow_blank: true

  before_validation :set_workspace_id

  after_commit :confirm_order, if: -> { saved_change_to_status? and success? }, on: [:create, :update]
  after_commit :refund_order, if: -> { saved_change_to_status? and refunded? }, on: [:create, :update]

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
      order.confirm!
    end

    def refund_order
      order.refund!
    end

    def set_workspace_id
      self.workspace_id = order.workspace_id if order
    end
end
