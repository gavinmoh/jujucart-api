class Api::V1::Storefront::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone_number, :active,
             :profile_photo, :role, :last_sign_in_at, :last_sign_in_ip,
             :workspace_id
  attributes :created_at, :updated_at
end
