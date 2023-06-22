class Workspace < ApplicationRecord
  belongs_to :owner, optional: true, class_name: 'Account'
  belongs_to :created_by, optional: true, class_name: 'Account'

  has_many :user_workspaces, dependent: :destroy
  has_many :users, through: :user_workspaces
  has_many :categories, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :inventories, dependent: :destroy
  has_many :inventory_transfers, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :pos_terminals, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :promotion_bundles, dependent: :destroy
  has_many :sales_statements, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :wallets, dependent: :destroy

  mount_base64_uploader :logo, PhotoUploader

  store_accessor :settings, [
    :web_host, :coin_to_cash_rate, :order_reward_amount, :maximum_redeemed_coin_rate, :invoice_size,
    :company_phone_number, :company_email, :company_name, :company_address, :bank_name, :bank_account_number,
    :bank_holder_name, :receipt_footer
  ]

  validates :subdomain,
    uniqueness: true,
    exclusion: { in: %w(www us ca jp app my), message: "%{value} is reserved." },
    if: -> { self.subdomain.present? }

  validates :web_host, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "is not a valid URL" }, if: -> { self.web_host.present? }
  validates :coin_to_cash_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, if: -> { self.coin_to_cash_rate.present? }
  validates :order_reward_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { self.order_reward_amount.present? }
  validates :maximum_redeemed_coin_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, if: -> { self.maximum_redeemed_coin_rate.present? }

  before_validation :set_owner_id, on: :create
  before_validation :set_default_settings, on: :create

  private
    def set_owner_id
      self.owner_id = self.created_by_id if self.owner_id.nil?
    end

    def set_default_settings
      self.coin_to_cash_rate = 0.01 if self.coin_to_cash_rate.blank?
      self.order_reward_amount = 0 if self.order_reward_amount.blank?
      self.maximum_redeemed_coin_rate = 0.5 if self.maximum_redeemed_coin_rate.blank?
      self.invoice_size = 'A4' if self.invoice_size.blank?
    end
end
