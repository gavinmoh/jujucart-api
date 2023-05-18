class Store < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :products, through: :inventories

  validates :name, presence: true

  mount_base64_uploader :logo, PhotoUploader

  has_paper_trail
end
