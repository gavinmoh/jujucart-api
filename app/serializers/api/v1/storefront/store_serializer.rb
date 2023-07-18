class Api::V1::Storefront::StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :logo, :hostname, :subdomain
  attributes :created_at, :updated_at
end
