class Api::V1::User::PosTerminalSerializer < ActiveModel::Serializer
  attributes :id, :terminal_id, :label, :store_id
  attributes :created_at, :updated_at
  has_one :store
end
