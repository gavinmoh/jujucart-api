class Api::V1::User::BestSellerProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :featured_photo, :category_id,
             :price, :discount_price, :is_featured, :slug, :tags, :has_no_variant,
             :is_cartable, :is_hidden, :sku, :nanoid, :type, :product_attributes
  attributes :created_at, :updated_at
  attribute :sold_quantity
  attribute :sales_amount
  has_one :category

  def sold_quantity
    object['sold_quantity']
  end
  
  def sales_amount
    Money.new(object['sales_amount_cents'])
  end
end
