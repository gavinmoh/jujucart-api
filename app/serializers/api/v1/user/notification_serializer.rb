class Api::V1::User::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :recipient_id, :subject, :message, :record_type, :record_id, 
             :read_at, :notification_type
  attributes :created_at, :updated_at
  has_one :recipient, serializer: Api::V1::User::UserInfoSerializer
end
