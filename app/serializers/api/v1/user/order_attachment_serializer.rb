class Api::V1::User::OrderAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :file, :name, :order_id
  attributes :created_at, :updated_at
  has_one :order
end
