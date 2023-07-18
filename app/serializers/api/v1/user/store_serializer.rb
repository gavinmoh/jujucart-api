class Api::V1::User::StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :logo, :validate_inventory,
             :store_type, :hostname, :subdomain
  attributes :created_at, :updated_at

  has_many :assigned_stores
  has_many :users, serializer: Api::V1::User::UserInfoSerializer
  has_many :pos_terminals
end
