class AssignedStore < ApplicationRecord
  belongs_to :user
  belongs_to :store

  validates :user, uniqueness: { scope: :store_id }
end
