class Store < ApplicationRecord
  belongs_to :workspace
  has_one  :location, dependent: :destroy
  has_many :inventories, through: :location
  has_many :orders, dependent: :nullify
  has_many :products, through: :inventories
  has_many :assigned_stores, dependent: :destroy
  has_many :users, through: :assigned_stores
  has_many :pos_terminals, dependent: :nullify

  after_commit :create_location, on: :create

  accepts_nested_attributes_for :assigned_stores, allow_destroy: true
  accepts_nested_attributes_for :pos_terminals, allow_destroy: true

  validates :name, presence: true

  mount_base64_uploader :logo, PhotoUploader

  has_paper_trail

  private
    def create_location
      Location.find_or_create_by(store_id: self.id, workspace_id: self.workspace_id)
    end
end
