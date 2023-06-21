class UserWorkspace < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  validates :user, uniqueness: { scope: :workspace_id }
end
