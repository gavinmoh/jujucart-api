class PromotionBundle < ApplicationRecord
  has_many :promotion_bundle_items, dependent: :destroy
  has_many :line_items, dependent: :nullify

  accepts_nested_attributes_for :promotion_bundle_items, allow_destroy: true

  monetize :discount_price_cents

  validates :name, presence: true
  enum discount_by: { percentage_discount: 'percentage_discount', price_discount: 'price_discount' }
  validates :discount_by, presence: true

  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_must_be_after_start_at

  validate :discount_price_must_be_more_than_zero_if_discount_by_price
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :discount_percentage, numericality: { greater_than: 0 }, allow_nil: false, if: -> { self.percentage_discount? }

  scope :active, -> { where('start_at <= ?', Time.zone.now).where('end_at >= ?', Time.zone.now) }
  scope :scheduled, -> { where('start_at > ?', Time.zone.now) }
  scope :expired, -> { where('end_at < ?', Time.zone.now) }

  private 
    def end_at_must_be_after_start_at
      return unless self.start_at.present? && self.end_at.present?
      return if self.end_at > self.start_at
      errors.add(:end_at, 'must be after start at')
    end

    def discount_price_must_be_more_than_zero_if_discount_by_price
      return unless self.price_discount?
      return unless self.discount_price_cents <= 0
      errors.add(:discount_price, 'must be more than zero')
    end
end
