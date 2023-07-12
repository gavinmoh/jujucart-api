class Api::V1::Storefront::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :featured_photo, :category_id,
             :price, :discount_price, :is_featured, :slug, :tags, :has_no_variant,
             :is_cartable, :is_hidden, :sku, :nanoid, :type, :product_attributes
  attributes :created_at, :updated_at
  attribute :product_quantity
  attribute :variant_quantity
  has_one :category
  has_many :product_variants do |serializer|
    instance_options = serializer.send(:instance_options)
    if instance_options[:product_variants].present?
      instance_options[:product_variants]
    else
      serializer.object.product_variants
    end
  end
end