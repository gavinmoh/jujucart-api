class Store < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :products, through: :inventories
  has_many :assigned_stores, dependent: :destroy
  has_many :users, through: :assigned_stores, class_name: 'Store'

  accepts_nested_attributes_for :assigned_stores, allow_destroy: true

  validates :name, presence: true

  mount_base64_uploader :logo, PhotoUploader

  has_paper_trail
end
