class OrderCoupon < ApplicationRecord
  belongs_to :order
  belongs_to :coupon, optional: true

  validates :code, presence: true, uniqueness: { case_sensitive: false, scope: :order_id }
  enum error_code: { 
    code_valid: 'code_valid', # avoid none or valid to avoid conflict with instance methods
    expired: 'expired', 
    minimum_spend_not_reached: 'minimum_spend_not_reached', 
    limit_reached: 'limit_reached', 
    not_found: 'not_found',
    not_active: 'not_active'
  }, _default: 'code_valid'

  monetize :discount_cents

  before_validation :upcase_code, if: -> { self.code.present? }
  before_validation :set_coupon, unless: -> { self.coupon_id.present? }

  before_save :calculate_discount, if: -> { self.code_changed? }

  after_commit :update_order_price

  def calculate_discount(apply_update = false)
    unless self.coupon.present?
      self.assign_attributes(error_code: :not_found, is_valid: false, discount_cents: 0)
      self.save! if apply_update
      return
    end

    if self.coupon.expired?
      self.assign_attributes(error_code: :expired, is_valid: false, discount_cents: 0)
      self.save! if apply_update
      return
    end

    unless self.coupon.active?
      self.assign_attributes(error_code: :not_active, is_valid: false, discount_cents: 0)
      self.save! if apply_update
      return
    end

    if self.coupon.limit_reached?
      self.assign_attributes(error_code: :limit_reached, is_valid: false, discount_cents: 0)
      self.save! if apply_update
      return
    end

    if (self.coupon.minimum_spend_cents > 0) && (self.order.subtotal_cents < self.coupon.minimum_spend_cents)
      self.assign_attributes(error_code: :minimum_spend_not_reached, is_valid: false, discount_cents: 0)
      self.save! if apply_update
      return
    end

    case self.coupon.discount_by
    when 'price_discount'
      self.assign_attributes(error_code: :code_valid, is_valid: true, discount: self.coupon.discount_price)
    when 'percentage_discount'
      calculated_discount = self.order.subtotal * (self.coupon.discount_percentage / 100.0)
      if self.coupon.maximum_capped?
        self.assign_attributes(error_code: :code_valid, is_valid: true, discount: [calculated_discount, self.coupon.maximum_cap].min)
      else
        self.assign_attributes(error_code: :code_valid, is_valid: true, discount: calculated_discount)
      end
    end
    self.save! if apply_update
  end

  private
    def upcase_code
      self.code = self.code.upcase
    end

    def set_coupon
      self.coupon = Coupon.find_by(code: self.code)
    end

    def update_order_price
      return if self.order.destroyed?
      return unless self.code_valid?
      self.order.reload
      self.order.recalculate_price(false) # skip recalculate coupon discount
    end
end
