class Product < BaseProduct
  include ActiveModel::Dirty

  belongs_to :workspace
  has_many :product_variants, dependent: :destroy, foreign_key: :product_id

  monetize :price_cents
  monetize :discount_price_cents
  
  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :name, presence: true

  after_commit :update_slug, if: -> { (not self.slug.present?) and saved_change_to_attribute?(:name) }

  scope :active, -> { where(active: true) }
  scope :query, -> (keyword) { where('products.name ILIKE ?', "%#{keyword}%") }
  scope :with_store_quantity, -> (store_id) do
    product_quantity_sql = <<-SQL
      LEFT OUTER JOIN (
        SELECT product_id, quantity AS product_quantity 
        FROM inventories
        LEFT JOIN locations on inventories.location_id = locations.id
        WHERE locations.store_id = \'#{store_id}\'
      ) AS product_inventories ON product_inventories.product_id = products.id
    SQL
    product_variant_quantity_sql = <<-SQL
      LEFT OUTER JOIN (
        SELECT
          sum(inventories.quantity) AS variant_quantity,
          products.product_id
        FROM
          inventories
          LEFT JOIN locations on inventories.location_id = locations.id
          LEFT OUTER JOIN products ON inventories.product_id = products.id
        WHERE
          products.type = 'ProductVariant'
          AND locations.store_id = \'#{store_id}\'
        GROUP BY
          products.product_id
      ) AS product_variant_inventories ON products.id = product_variant_inventories.product_id
    SQL
    select('products.*, coalesce(product_inventories.product_quantity, 0) AS product_quantity, coalesce(product_variant_inventories.variant_quantity, 0) AS variant_quantity')
      .joins(product_quantity_sql.squish)
      .joins(product_variant_quantity_sql.squish)
  end

  private
    def update_slug
      new_slug ||= self.name.parameterize
      self.update(slug: new_slug)
    rescue ActiveRecord::RecordNotUnique
      new_slug = new_slug + '-' + self.nanoid
      retry
    end

end
