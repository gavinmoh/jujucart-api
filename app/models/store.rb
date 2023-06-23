class Store < ApplicationRecord
  belongs_to :workspace
  has_one  :location, dependent: :destroy
  has_many :inventories, through: :location
  has_many :orders, dependent: :nullify
  has_many :products, through: :inventories
  has_many :assigned_stores, dependent: :destroy
  has_many :users, through: :assigned_stores
  has_many :pos_terminals, dependent: :nullify

  after_commit :create_location, on: :create

  accepts_nested_attributes_for :assigned_stores, allow_destroy: true
  accepts_nested_attributes_for :pos_terminals, allow_destroy: true

  enum store_type: { physical: 'physical', online: 'online' }, _default: 'physical'

  validates :name, presence: true
  validates :hostname, format: { with: /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/ }, 
                       uniqueness: { case_sensitive: false }, 
                       allow_blank: true
  validate :hostname_is_not_private_ip, if: -> { hostname.present? }
  validate :hostname_is_not_localhost, if: -> { hostname.present? }

  before_validation :format_hostname, if: -> { hostname.present? }

  mount_base64_uploader :logo, PhotoUploader

  has_paper_trail

  private
    def create_location
      Location.find_or_create_by(store_id: self.id, workspace_id: self.workspace_id)
    end

    def format_hostname
      self.hostname = hostname.downcase
                              .gsub(/\s+/, "") # remove whitespace
                              .gsub(/\A\.+|\.+\z/, "") # remove leading and trailing dots
                              .gsub(/\Ahttp(s)?:\/\//, "") # remove http:// or https://
                              .gsub(/\/.*\z/, "") # remove everything after the first slash
    end

    def hostname_is_not_private_ip
      if hostname.present? && IPAddr.new(hostname).private?
        errors.add(:hostname, "can't be a private IP address")
      end
    rescue IPAddr::InvalidAddressError
      nil
    end

    def hostname_is_not_localhost
      if hostname.present? && hostname.include?('localhost')
        errors.add(:hostname, "can't be localhost")
      end
    end
end
