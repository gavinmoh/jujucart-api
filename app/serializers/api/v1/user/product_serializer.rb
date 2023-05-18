class Api::V1::User::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :featured_photo, :category_id,
             :price, :discount_price, :is_featured, :slug, :tags, :has_no_variant,
             :is_cartable, :is_hidden, :sku, :nanoid, :type, :product_attributes
  attributes :created_at, :updated_at
  attribute :product_quantity, if: -> { @instance_options and @instance_options[:include_store_quantity] == true }
  attribute :variant_quantity, if: -> { @instance_options and @instance_options[:include_store_quantity] == true }
  has_one :category
  has_many :product_variants do
    if @instance_options and @instance_options[:store_id].present?
      object.product_variants.with_store_quantity(@instance_options[:store_id])
    else
      object.product_variants
    end
  end
end
