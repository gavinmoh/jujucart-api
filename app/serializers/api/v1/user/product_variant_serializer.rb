class Api::V1::User::ProductVariantSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :featured_photo,
             :price, :discount_price, :is_featured, :sku, :nanoid, 
             :type, :product_attributes, :product_id
  attributes :created_at, :updated_at
  has_one :product
  attribute :product_quantiy

  def product_quantiy
    object['product_quantity']
  end
end
