class ProductAddon < BaseProduct
  belongs_to :product, touch: true, optional: true
  belongs_to :workspace, optional: true

  before_validation :set_workspace_id

  validates :name, presence: true

  scope :with_store_quantity, lambda { |store_id|
    product_addon_quantity_sql = <<-SQL.squish
      LEFT OUTER JOIN (
        SELECT
          product_id,          quantity AS addon_quantity
        FROM
          inventories
          LEFT JOIN locations on inventories.location_id = locations.id
        WHERE
          locations.store_id = \'#{store_id}\'
      ) AS product_addon_inventories ON products.id = product_addon_inventories.product_id
    SQL
    select('products.*, coalesce(product_addon_inventories.addon_quantity, 0) AS product_quantity')
      .joins(product_addon_quantity_sql)
  }

  private

    def set_workspace_id
      self.workspace_id = product&.workspace_id
    end
end
