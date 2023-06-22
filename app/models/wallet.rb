class Wallet < ApplicationRecord
  belongs_to :workspace
  belongs_to :customer, optional: true

  has_many :wallet_transactions, dependent: :destroy

  before_validation :set_workspace_id

  private
    def set_workspace_id
      self.workspace_id = self.customer.workspace_id if self.customer
    end
end
