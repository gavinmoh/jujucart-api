class Api::V1::User::UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone_number, :active, 
             :profile_photo, :role, :last_sign_in_at, :last_sign_in_ip
  attributes :created_at, :updated_at

  has_many :assigned_stores
  has_many :stores
end
