class Product < BaseProduct
  include ActiveModel::Dirty

  belongs_to :workspace
  has_many :product_variants, dependent: :destroy, inverse_of: :product
  has_many :product_addons, dependent: :destroy, inverse_of: :product

  monetize :price_cents
  monetize :discount_price_cents

  accepts_nested_attributes_for :product_variants, allow_destroy: true
  accepts_nested_attributes_for :product_addons, allow_destroy: true

  validates :name, presence: true

  before_save :set_slug, if: :name_changed?

  scope :active, -> { where(active: true) }
  scope :query, ->(keyword) { where('products.name ILIKE ?', "%#{keyword}%") }
  scope :with_store_quantity, lambda { |store_id, include_all_products = true|
    product_quantity_sql = <<-SQL.squish
      LEFT OUTER JOIN (
        SELECT product_id, quantity AS product_quantity, inventories.id as inventory_id
        FROM inventories
        LEFT JOIN locations on inventories.location_id = locations.id
        WHERE locations.store_id = \'#{store_id}\'
      ) AS product_inventories ON product_inventories.product_id = products.id
    SQL
    product_variant_quantity_sql = <<-SQL.squish
      LEFT OUTER JOIN (
        SELECT
          sum(inventories.quantity) AS variant_quantity,
          products.product_id,
          array_agg(inventories.id) as variant_inventory_ids
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
    product_addon_quantity_sql = <<-SQL.squish
      LEFT OUTER JOIN (
        SELECT
          sum(inventories.quantity) AS addon_quantity,
          products.product_id,
          array_agg(inventories.id) as addon_inventory_ids
        FROM
          inventories
          LEFT JOIN locations on inventories.location_id = locations.id
          LEFT OUTER JOIN products ON inventories.product_id = products.id
        WHERE
          products.type = 'ProductAddon'
          AND locations.store_id = \'#{store_id}\'
        GROUP BY
          products.product_id
      ) AS product_addon_inventories ON products.id = product_addon_inventories.product_id
    SQL
    selection_query = <<-SQL.squish
      products.*,
      product_inventories.inventory_id,
      product_variant_inventories.variant_inventory_ids,
      product_addon_inventories.addon_inventory_ids,
      coalesce(product_inventories.product_quantity, 0) AS product_quantity,
      coalesce(product_variant_inventories.variant_quantity, 0) AS variant_quantity,
      coalesce(product_addon_inventories.addon_quantity, 0) AS addon_quantity
    SQL
    scope = select(selection_query).joins(product_quantity_sql)
                                   .joins(product_variant_quantity_sql)
                                   .joins(product_addon_quantity_sql)
    if include_all_products
      scope
    else
      scope.where('inventory_id IS NOT NULL OR variant_inventory_ids IS NOT NULL OR addon_inventory_ids IS NOT NULL')
    end
  }

  private

    def set_slug
      new_slug ||= name.parameterize
      return if slug == new_slug

      self.slug = if self.class.where.not(id: id).exists?(workspace_id: workspace_id, slug: new_slug)
                    "#{new_slug}-#{SecureRandom.hex(4)}"
                  else
                    new_slug
                  end
    end
end
