class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  mount_base64_uploader :photo, PhotoUploader

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }
  scope :with_sold_quantity_and_sales_amount_cents, -> {
    select_query = <<-SQL
      categories.*,
      COALESCE(products.category_id, products_products.category_id) AS group_id,
      SUM(line_items.quantity) AS sold_quantity, 
      SUM(line_items.total_price_cents) AS sales_amount_cents
    SQL

    left_joins(products: [line_items: { product: :product }])
      .select(select_query.squish)
      .group('categories.id', 'group_id')
      .having('SUM(line_items.quantity) IS NOT NULL')
  }

  after_commit :update_slug, if: -> { self.name.present? and (saved_change_to_attribute?(:name) or (not self.slug.present?)) }

  has_paper_trail

  private
    def update_slug
      new_slug ||= self.name.parameterize
      self.update(slug: new_slug)
    rescue ActiveRecord::RecordNotUnique
      new_slug = new_slug + '-' + SecureRandom.hex(3)
      retry
    end
end
