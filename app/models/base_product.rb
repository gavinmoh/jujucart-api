class BaseProduct < ApplicationRecord
  self.table_name = "products"
  include ActiveModel::Dirty

  monetize :price_cents
  monetize :discount_price_cents
  mount_base64_uploader :featured_photo, PhotoUploader

  has_many :line_items, dependent: :nullify, foreign_key: :product_id
  has_many :inventories, dependent: :destroy, foreign_key: :product_id

  has_paper_trail

  after_commit :update_line_items, on: :update
  before_destroy :mark_line_items_product_deleted

  private
    def mark_line_items_product_deleted
      self.line_items.update_all(product_deleted: true)
    end

    def update_line_items
      LineItem.joins_with_pending_orders
              .where(product_id: self.id)
              .each { |line_item| line_item.save }
    end

end