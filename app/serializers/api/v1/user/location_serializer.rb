class Api::V1::User::LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :display_name, :store_id
  attributes :created_at, :updated_at
  has_one :store

  def display_name
    object.store.present? ? object.store.name : object.name
  end
end
