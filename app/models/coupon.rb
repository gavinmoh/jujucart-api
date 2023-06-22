class Coupon < ApplicationRecord
  belongs_to :workspace
  has_many :order_coupons, dependent: :nullify
  has_many :orders, through: :order_coupons

  validates :code, presence: true, uniqueness: { case_sensitive: false, scope: :workspace_id }
  validates :name, presence: true
  validates :redemption_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_must_be_after_start_at
  validate :order_types_must_have_at_least_one
  validate :order_types_must_be_valid

  enum discount_by: { price_discount: 'price_discount', percentage_discount: 'percentage_discount' }
  validates :discount_by, presence: true

  enum coupon_type: { promotion: 'promotion' }
  validates :coupon_type, presence: true

  enum discount_on: { delivery_fee: 'delivery_fee', subtotal: 'subtotal' }
  validates :discount_on, presence: true

  validate  :discount_price_must_be_more_than_zero_if_discount_by_price
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :discount_percentage, numericality: { greater_than: 0 }, allow_nil: false, if: -> { self.percentage_discount? }

  before_validation :upcase_code, :set_maximum_cap

  monetize :discount_price_cents
  monetize :minimum_spend_cents
  monetize :maximum_cap_cents

  scope :active, -> { where('start_at <= ?', Time.zone.now).where('end_at >= ?', Time.zone.now) }
  scope :scheduled, -> { where('start_at > ?', Time.zone.now) }
  scope :expired, -> { where('end_at < ?', Time.zone.now) }
  scope :with_total_redemptions, -> { 
    select('coupons.*, COUNT(order_coupons.id) AS total_redemptions')
      .left_joins({order_coupons: :order})
      .where.not(orders: { status: 'pending'})
      .where(order_coupons: { is_valid: true })
      .group('coupons.id') 
  }

  def total_redemptions
    self.order_coupons.joins(:order).where.not(orders: { status: 'pending'}).where(is_valid: true).count
  end

  def active?
    self.start_at <= Time.zone.now && self.end_at >= Time.zone.now
  end

  def expired?
    self.end_at < Time.zone.now
  end

  def limit_reached?
    total_redemptions >= self.redemption_limit
  end

  def maximum_capped?
    self.maximum_cap_cents > 0
  end

  private
    def end_at_must_be_after_start_at
      return unless self.start_at.present? && self.end_at.present?
      return if self.end_at > self.start_at
      errors.add(:end_at, 'must be after start at')
    end

    def order_types_must_have_at_least_one
      return unless self.order_types.empty?
      errors.add(:order_types, 'must have at least one')
    end

    def order_types_must_be_valid
      return unless self.order_types.present?
      self.order_types.each do |order_type|
        unless Order.order_types.keys.include?(order_type)
          errors.add(:order_types, "#{order_type} is not valid")
        end
      end
    end

    def discount_price_must_be_more_than_zero_if_discount_by_price
      return unless self.price_discount?
      return unless self.discount_price_cents <= 0
      errors.add(:discount_price, 'must be more than zero')
    end

    def upcase_code
      return unless self.code.present?
      self.code = self.code.upcase
    end

    def set_maximum_cap
      return unless self.price_discount?
      self.maximum_cap_cents = self.discount_price_cents
    end
end
