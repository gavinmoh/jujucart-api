class Api::V1::User::StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :logo, :validate_inventory
  attributes :created_at, :updated_at
end
