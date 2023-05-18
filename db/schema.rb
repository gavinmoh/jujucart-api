# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_17_102952) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "type", null: false
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "active", default: true
    t.string "nanoid"
    t.string "role"
    t.string "profile_photo"
    t.index ["email", "type"], name: "index_accounts_on_email_and_type", unique: true, where: "((email IS NOT NULL) AND ((email)::text <> ''::text))"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["phone_number", "type"], name: "index_accounts_on_phone_number_and_type", unique: true, where: "((phone_number IS NOT NULL) AND ((phone_number)::text <> ''::text))"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
  end

  create_table "assigned_stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_assigned_stores_on_store_id"
    t.index ["user_id"], name: "index_assigned_stores_on_user_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "display_order"
    t.string "photo"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.uuid "product_id", null: false
    t.integer "quantity", default: 0, null: false
    t.string "nanoid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nanoid"], name: "index_inventories_on_nanoid", unique: true
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["store_id"], name: "index_inventories_on_store_id"
  end

  create_table "inventory_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id"
    t.uuid "inventory_id", null: false
    t.integer "quantity", default: 0, null: false
    t.text "description"
    t.string "nanoid"
    t.bigint "price_cents", default: 0, null: false
    t.string "price_currency", default: "MYR", null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.string "unit_price_currency", default: "MYR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_inventory_transactions_on_inventory_id"
    t.index ["nanoid"], name: "index_inventory_transactions_on_nanoid", unique: true
    t.index ["order_id"], name: "index_inventory_transactions_on_order_id"
  end

  create_table "line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "product_id"
    t.integer "quantity", default: 1, null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.string "unit_price_currency", default: "MYR", null: false
    t.bigint "total_price_cents", default: 0, null: false
    t.string "total_price_currency", default: "MYR", null: false
    t.string "name"
    t.boolean "product_deleted"
    t.jsonb "product_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
  end

  create_table "notification_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipient_id"
    t.string "device_uid"
    t.string "token"
    t.string "device_model"
    t.string "device_os"
    t.string "app_name"
    t.string "app_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_notification_tokens_on_recipient_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipient_id", null: false
    t.string "subject"
    t.text "message"
    t.string "record_type"
    t.uuid "record_id"
    t.datetime "read_at", precision: nil
    t.string "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["record_type", "record_id"], name: "index_notifications_on_record"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "order_type"
    t.string "nanoid"
    t.uuid "customer_id"
    t.string "status"
    t.bigint "total_cents", default: 0, null: false
    t.string "total_currency", default: "MYR", null: false
    t.bigint "subtotal_cents", default: 0, null: false
    t.string "subtotal_currency", default: "MYR", null: false
    t.bigint "delivery_fee_cents", default: 0, null: false
    t.string "delivery_fee_currency", default: "MYR", null: false
    t.bigint "discount_cents", default: 0, null: false
    t.string "discount_currency", default: "MYR", null: false
    t.boolean "is_flagged"
    t.string "flagged_reason"
    t.uuid "store_id"
    t.string "unit_number"
    t.string "street_address1"
    t.string "street_address2"
    t.string "postcode"
    t.string "city"
    t.string "state"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "courier_name"
    t.string "tracking_number"
    t.bigint "reward_coin", default: 0
    t.integer "redeemed_coin", default: 0
    t.bigint "redeemed_coin_value_cents", default: 0, null: false
    t.string "redeemed_coin_value_currency", default: "MYR", null: false
    t.datetime "pending_payment_at"
    t.datetime "confirmed_at"
    t.datetime "packed_at"
    t.datetime "shipped_at"
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.datetime "failed_at"
    t.uuid "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_orders_on_created_by_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["nanoid"], name: "index_orders_on_nanoid", unique: true
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id"
    t.string "status"
    t.string "payment_type"
    t.string "nanoid"
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "MYR", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nanoid"], name: "index_payments_on_nanoid", unique: true
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.string "featured_photo"
    t.uuid "category_id"
    t.bigint "price_cents", default: 0, null: false
    t.string "price_currency", default: "MYR", null: false
    t.bigint "discount_price_cents", default: 0, null: false
    t.string "discount_price_currency", default: "MYR", null: false
    t.boolean "is_featured", default: false
    t.string "slug"
    t.string "tags", default: [], array: true
    t.boolean "has_no_variant", default: true
    t.boolean "is_cartable", default: true
    t.boolean "is_hidden", default: false
    t.string "sku"
    t.string "nanoid"
    t.string "type"
    t.jsonb "product_attributes", default: [], null: false, array: true
    t.uuid "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["nanoid"], name: "index_products_on_nanoid", unique: true
    t.index ["product_id"], name: "index_products_on_product_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true, where: "((sku IS NOT NULL) AND ((sku)::text <> ''::text))"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "scope"
    t.string "token"
    t.datetime "revoked_at"
    t.datetime "expired_at"
    t.string "user_agent"
    t.string "remote_ip"
    t.string "referer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "logo"
    t.boolean "validate_inventory", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "item_subtype"
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "ip"
    t.string "user_agent"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wallet_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wallet_id", null: false
    t.string "transaction_type"
    t.bigint "amount"
    t.uuid "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_wallet_transactions_on_order_id"
    t.index ["wallet_id"], name: "index_wallet_transactions_on_wallet_id"
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.bigint "current_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_wallets_on_customer_id"
  end

  add_foreign_key "assigned_stores", "accounts", column: "user_id"
  add_foreign_key "assigned_stores", "stores"
  add_foreign_key "inventories", "products"
  add_foreign_key "inventories", "stores"
  add_foreign_key "inventory_transactions", "inventories"
  add_foreign_key "inventory_transactions", "orders"
  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "products"
  add_foreign_key "notification_tokens", "accounts", column: "recipient_id"
  add_foreign_key "notifications", "accounts", column: "recipient_id"
  add_foreign_key "orders", "accounts", column: "created_by_id"
  add_foreign_key "orders", "accounts", column: "customer_id"
  add_foreign_key "orders", "stores"
  add_foreign_key "payments", "orders"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "products"
  add_foreign_key "sessions", "accounts"
  add_foreign_key "wallet_transactions", "orders"
  add_foreign_key "wallet_transactions", "wallets"
  add_foreign_key "wallets", "accounts", column: "customer_id"
end
