class Api::V1::User::UserInfoSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone_number, :active, :email, :role, :profile_photo
  attributes :created_at, :updated_at
end
