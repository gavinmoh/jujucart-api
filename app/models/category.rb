class Category < ApplicationRecord
  belongs_to :workspace
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :workspace_id }
  validates :slug, uniqueness: { case_sensitive: false, scope: :workspace_id }, allow_blank: true

  mount_base64_uploader :photo, PhotoUploader

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }
  scope :with_sold_quantity_and_sales_amount_cents, lambda {
    select_query = <<-SQL.squish
      categories.*,
      COALESCE(products.category_id, products_products.category_id) AS group_id,
      SUM(line_items.quantity) AS sold_quantity,#{' '}
      SUM(line_items.total_price_cents) AS sales_amount_cents
    SQL

    left_joins(products: [line_items: { product: :product }])
      .select(select_query)
      .group('categories.id', 'group_id')
      .having('SUM(line_items.quantity) IS NOT NULL')
  }

  after_commit :update_slug, if: -> { name.present? and (saved_change_to_attribute?(:name) or slug.blank?) }

  has_paper_trail

  private

    def update_slug
      new_slug ||= name.parameterize
      update(slug: new_slug)
    rescue ActiveRecord::RecordNotUnique
      new_slug = "#{new_slug}-#{SecureRandom.hex(3)}"
      retry
    end
end
