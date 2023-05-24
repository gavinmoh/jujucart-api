class BaseProduct < ApplicationRecord
  self.table_name = "products"
  include ActiveModel::Dirty

  belongs_to :category, optional: true
  belongs_to :product, optional: true, class_name: 'BaseProduct'

  has_many :line_items, dependent: :nullify, foreign_key: :product_id
  has_many :inventories, dependent: :destroy, foreign_key: :product_id
  has_many :promotion_bundle_items, dependent: :destroy, foreign_key: :product_id
  has_many :inventory_transfer_items, dependent: :nullify, foreign_key: :product_id

  monetize :price_cents
  monetize :discount_price_cents
  mount_base64_uploader :featured_photo, PhotoUploader

  validates :sku, uniqueness: true, allow_nil: true, allow_blank: true

  has_paper_trail

  after_commit :update_line_items, on: :update
  before_destroy :mark_line_items_product_deleted, prepend: true

  scope :with_sold_quantity_and_sales_amount_cents, -> {
    joins(:line_items)
      .select('products.*, SUM(line_items.quantity) AS sold_quantity, SUM(line_items.total_price_cents) AS sales_amount_cents')
      .group('products.id')
  }

  private
    def update_line_items
      LineItem.joins_with_pending_orders.where(product_id: self.id).find_each { |line_item| line_item.save }
      LineItem.joins_with_parent_product(self.id).joins_with_pending_orders.find_each { |line_item| line_item.save }
    end

    def mark_line_items_product_deleted
      self.line_items.update_all(product_deleted: true) 
    end

end