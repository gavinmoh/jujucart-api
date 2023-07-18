class Store < ApplicationRecord
  belongs_to :workspace
  has_one  :location, dependent: :destroy
  has_many :inventories, through: :location
  has_many :orders, dependent: :nullify
  has_many :products, through: :inventories
  has_many :assigned_stores, dependent: :destroy
  has_many :users, through: :assigned_stores
  has_many :pos_terminals, dependent: :nullify

  before_validation :set_subdomain, if: -> { name.present? and subdomain.blank? }
  before_validation :format_hostname, if: -> { hostname.present? }
  before_validation :format_subdomain, if: -> { subdomain.present? }
  after_commit :create_location, on: :create

  accepts_nested_attributes_for :assigned_stores, allow_destroy: true
  accepts_nested_attributes_for :pos_terminals, allow_destroy: true

  enum store_type: { physical: 'physical', online: 'online' }, _default: 'physical'

  store_accessor :data, [:billplz_collection_id]

  validates :name, presence: true
  validates :hostname, format: { with: /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/ },
                       uniqueness: { case_sensitive: false },
                       allow_blank: true
  validates :subdomain,
            uniqueness: true,
            exclusion: { in: %w[www us ca jp app my store], message: "%<value>s is reserved." },
            if: -> { subdomain.present? }
  validate :hostname_is_not_private_ip, if: -> { hostname.present? }
  validate :hostname_is_not_localhost, if: -> { hostname.present? }

  mount_base64_uploader :logo, PhotoUploader

  has_paper_trail

  private

    def create_location
      Location.find_or_create_by(store_id: id, workspace_id: workspace_id)
    end

    def set_subdomain
      new_subdomain = name.downcase.gsub(/[^a-zA-Z0-9\-]/, "").parameterize
      new_subdomain = "#{new_subdomain}-#{SecureRandom.hex(4)}" if self.class.exists?(subdomain: new_subdomain)
      self.subdomain = new_subdomain
    end

    def format_hostname
      self.hostname = hostname.downcase
                              .gsub(/\s+/, "") # remove whitespace
                              .gsub(/\A\.+|\.+\z/, "") # remove leading and trailing dots
                              .gsub(%r{\Ahttp(s)?://}, "") # remove http:// or https://
                              .gsub(%r{/.*\z}, "") # remove everything after the first slash
    end

    def format_subdomain
      self.subdomain = subdomain.strip.downcase.gsub(/[^a-zA-Z0-9\-]/, "")
    end

    def hostname_is_not_private_ip
      errors.add(:hostname, "can't be a private IP address") if hostname.present? && IPAddr.new(hostname).private?
    rescue IPAddr::InvalidAddressError
      nil
    end

    def hostname_is_not_localhost
      errors.add(:hostname, "can't be localhost") if hostname.present? && hostname.include?('localhost')
    end
end
