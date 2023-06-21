class Api::V1::User::AssignedStoreSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :store_id
  attributes :created_at, :updated_at
  has_one :user, serializer: Api::V1::User::UserInfoSerializer
  has_one :store
end
