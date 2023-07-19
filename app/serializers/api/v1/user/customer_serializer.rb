class Api::V1::User::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone_number, :active, :email, :profile_photo, :stripe_customer_id
  attributes :created_at, :updated_at
  has_one :wallet
end
