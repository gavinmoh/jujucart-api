class Api::V1::User::AssignedStoreSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :store_id
  attributes :created_at, :updated_at
  has_one :user
  has_one :store
end
