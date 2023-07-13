class Api::V1::Storefront::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :featured_photo, :category_id,
             :price, :discount_price, :is_featured, :slug, :tags, :has_no_variant,
             :is_cartable, :is_hidden, :sku, :nanoid, :type, :product_attributes
  attributes :created_at, :updated_at
  attribute :product_quantity, if: -> { @instance_options[:include_store_quantity] == true }
  attribute :variant_quantity, if: -> { @instance_options[:include_store_quantity] == true }
  attribute :addon_quantity, if: -> { @instance_options[:include_store_quantity] == true }
  has_one :category
  has_many :product_variants do |serializer|
    instance_options = serializer.send(:instance_options)
    instance_options[:product_variants].presence || serializer.object.product_variants
  end
  has_many :product_addons do |serializer|
    instance_options = serializer.send(:instance_options)
    instance_options[:product_addons].presence || serializer.object.product_addons
  end
end
