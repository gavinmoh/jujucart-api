class Api::V1::User::BestSellerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :display_order, :photo
  attributes :created_at, :updated_at

  has_many :products, serializer: Api::V1::User::BestSellerProductSerializer do |serializer|
    serializer.send(:instance_options)[:products].select do |product| 
      product.type == 'ProductVariant' ? object.id == product.product.category_id : product.category_id == object.id
    end
  end
end
