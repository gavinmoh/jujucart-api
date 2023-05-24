class Location < ApplicationRecord
  belongs_to :store, optional: true

  has_many :inventories, dependent: :destroy

  validates :name, presence: true, unless: -> { self.store.present? }

  scope :query, -> (keyword) { left_joins(:store).where('locations.name ILIKE :keyword OR stores.name ILIKE :keyword', keyword: "%#{keyword}%")}
  scope :non_store, -> { where(store_id: nil) }
end
