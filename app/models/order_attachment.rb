class OrderAttachment < ApplicationRecord
  belongs_to :order

  validates :file, presence: true
  validates :name, presence: true

  mount_base64_uploader :file, FileUploader

  scope :query, -> (keyword) { where('order_attachments.name ILIKE :keyword', {keyword: "%#{keyword}%"}) }
end
