class Api::V1::User::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :display_order, :photo, :slug
  attributes :created_at, :updated_at
end
