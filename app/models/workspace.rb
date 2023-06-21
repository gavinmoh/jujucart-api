class Workspace < ApplicationRecord
  belongs_to :owner, optional: true, class_name: 'Account'
  belongs_to :created_by, optional: true, class_name: 'Account'

  has_many :user_workspaces, dependent: :destroy
  has_many :users, through: :user_workspaces

  mount_base64_uploader :logo, PhotoUploader

  store_accessor :settings, [:web_host, :coin_to_cash_rate, :order_reward_amount, :maximum_redeemed_coin_rate, :statement_address, :invoice_size]

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
      self.statement_address = '6623 & 6627, Jalan Mengkuang, Kampung Paya, 12200 Butterworth, Pulau Pinang.' if self.statement_address.blank?
      self.invoice_size = 'A4' if self.invoice_size.blank?
    end
end
