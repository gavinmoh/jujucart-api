class Api::V1::User::NotificationTokenSerializer < ActiveModel::Serializer
  attributes :id, :recipient_id, :device_uid, :token, :device_model, :device_os, :app_name,
             :app_version
  attributes :created_at, :updated_at
  has_one :recipient, serializer: Api::V1::User::UserInfoSerializer
end
