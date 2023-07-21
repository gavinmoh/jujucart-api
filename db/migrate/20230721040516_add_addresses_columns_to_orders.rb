class AddAddressesColumnsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :billing_address_unit_number, :string
    add_column :orders, :billing_address_street_address1, :string
    add_column :orders, :billing_address_street_address2, :string
    add_column :orders, :billing_address_postcode, :string
    add_column :orders, :billing_address_city, :string
    add_column :orders, :billing_address_state, :string
    add_column :orders, :billing_address_country, :string
    add_column :orders, :billing_address_latitude, :decimal, precision: 10, scale: 6
    add_column :orders, :billing_address_longitude, :decimal, precision: 10, scale: 6
    add_column :orders, :billing_address_contact_name, :string
    add_column :orders, :billing_address_contact_email, :string
    add_column :orders, :billing_address_contact_phone_number, :string

    rename_column :orders, :unit_number, :delivery_address_unit_number
    rename_column :orders, :street_address1, :delivery_address_street_address1
    rename_column :orders, :street_address2, :delivery_address_street_address2
    rename_column :orders, :postcode, :delivery_address_postcode
    rename_column :orders, :city, :delivery_address_city
    rename_column :orders, :state, :delivery_address_state
    rename_column :orders, :latitude, :delivery_address_latitude
    rename_column :orders, :longitude, :delivery_address_longitude
    rename_column :orders, :customer_name, :delivery_address_contact_name
    rename_column :orders, :customer_email, :delivery_address_contact_email
    rename_column :orders, :customer_phone_number, :delivery_address_contact_phone_number
    add_column :orders, :delivery_address_country, :string
  end
end
