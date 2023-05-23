class Api::V1::User::InventoryTransferSerializer < ActiveModel::Serializer
  attributes :id, :nanoid, :remark, :acceptance_remark, :status, 
             :transferred_at, :accepted_at, :cancelled_at, :reverted_at,
             :transfer_from_location_id, :transfer_to_location_id,
             :transferred_by_id, :accepted_by_id, :cancelled_by_id, :reverted_by_id,
             :created_by_id
  attributes :created_at, :updated_at
  has_one :transfer_from_location
  has_one :transfer_to_location
  has_one :transferred_by, serializer: Api::V1::User::UserInfoSerializer
  has_one :accepted_by, serializer: Api::V1::User::UserInfoSerializer
  has_one :cancelled_by, serializer: Api::V1::User::UserInfoSerializer
  has_one :reverted_by, serializer: Api::V1::User::UserInfoSerializer
  has_one :created_by, serializer: Api::V1::User::UserInfoSerializer
end
