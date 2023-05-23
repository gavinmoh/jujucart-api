class Api::V1::User::BestSellerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :display_order, :photo
  attributes :created_at, :updated_at

  has_many :products do |serializer|
    serializer.send(:instance_options)[:products].select { |product| product.category_id == object.id }
  end
end
