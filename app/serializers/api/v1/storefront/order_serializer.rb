class Api::V1::Storefront::OrderSerializer < ActiveModel::Serializer
  attributes :id, :order_type, :nanoid, :customer_id, :status, :total,
             :subtotal, :delivery_fee, :discount, :store_id,
             :courier_name, :tracking_number, :reward_coin, :pending_payment_at, :confirmed_at, :packed_at,
             :shipped_at, :completed_at, :cancelled_at, :failed_at, :created_by_id, :redeemed_coin, :redeemed_coin_value,
             :voided_at, :refunded_at
  attributes :billing_address_unit_number, :billing_address_street_address1, :billing_address_street_address2,
             :billing_address_postcode, :billing_address_city, :billing_address_state, :billing_address_country,
             :billing_address_latitude, :billing_address_longitude, :billing_address_contact_name,
             :billing_address_contact_email, :billing_address_contact_phone_number
  attributes :delivery_address_unit_number, :delivery_address_street_address1, :delivery_address_street_address2,
             :delivery_address_postcode, :delivery_address_city, :delivery_address_state, :delivery_address_country,
             :delivery_address_latitude, :delivery_address_longitude, :delivery_address_contact_name,
             :delivery_address_contact_email, :delivery_address_contact_phone_number
  attributes :created_at, :updated_at
  attribute :payment_url, if: -> { object.pending_payment? }

  has_one :store
  has_one :order_coupon
  has_many :line_items
  has_one :success_payment
  has_many :payments
  has_many :order_attachments

  def payment_url
    case object.workspace.default_payment_gateway
    when 'Billplz'
      return object.pending_billplz_payment&.billplz&.dig('url')
    when 'Stripe'
      return object.pending_stripe_payment&.stripe&.dig('url')
    end

    nil
  end
end
