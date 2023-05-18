class Api::V1::User::SessionSerializer < ActiveModel::Serializer
  attributes :id, :account_id, :scope, :revoked_at, :expired_at, 
             :user_agent, :remote_ip, :referer
  attributes :created_at, :updated_at
  has_one :account, serializer: Api::V1::User::UserInfoSerializer
end
