class Api::V1::Admin::WorkspaceSerializer < ActiveModel::Serializer
  attributes :id, :name, :settings, :logo, :subdomain, :owner_id, 
             :created_by_id, :nanoid, :company_phone_number, 
             :company_email, :company_name, :company_address, 
             :bank_name, :bank_account_number,
             :bank_holder_name, :receipt_footer
  attributes :created_at, :updated_at
  has_one :owner, serializer: Api::V1::Admin::UserInfoSerializer
  has_one :created_by, serializer: Api::V1::Admin::UserInfoSerializer
end
