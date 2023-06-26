class Api::V1::Storefront::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :display_order, :photo, :slug
  attributes :created_at, :updated_at
end
