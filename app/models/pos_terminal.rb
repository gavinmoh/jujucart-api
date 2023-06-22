class PosTerminal < ApplicationRecord
  belongs_to :workspace
  belongs_to :store, optional: true

  before_validation :set_workspace_id

  private
    def set_workspace_id
      self.workspace_id = self.store.workspace_id if self.store.present?
    end
end
