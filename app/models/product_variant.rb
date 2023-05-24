class ProductVariant < BaseProduct
  belongs_to :product, touch: true, optional: true
  
  validate :product_attributes_must_exist
  validates_uniqueness_of :product_attributes, scope: :product_id

  before_validation :format_product_attributes, if: -> { self.product_attributes.any? }

  scope :with_store_quantity, -> (store_id) do
    product_variant_quantity_sql = <<-SQL
      LEFT OUTER JOIN (
        SELECT
          product_id,
          quantity AS variant_quantity
        FROM
          inventories
          LEFT JOIN locations on inventories.location_id = locations.id
        WHERE
          locations.store_id = \'#{store_id}\'
      ) AS product_variant_inventories ON products.id = product_variant_inventories.product_id
    SQL
    select('products.*, coalesce(product_variant_inventories.variant_quantity, 0) AS product_quantity')
      .joins(product_variant_quantity_sql.squish)
  end

  private
    def product_attributes_must_exist
      self.errors.add(:product_attributes, 'must exist') unless self.product_attributes.any?
    end

    def format_product_attributes
      self.product_attributes = self.product_attributes.map do |product_attribute| 
        product_attribute.is_a?(Hash) ? product_attribute.transform_values!(&:strip) : product_attribute.strip
      end
    end
end
