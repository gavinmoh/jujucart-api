class Api::V1::User::SalesStatementSerializer < ActiveModel::Serializer
  attributes :id, :nanoid, :statement_number, :from_date, :to_date, :total_sales, 
             :total_delivery_fee, :total_discount, :total_redeemed_coin, 
             :total_gross_profit, :file
  attributes :created_at, :updated_at
end
