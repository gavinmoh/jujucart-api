class SalesStatement < ApplicationRecord
  validates :from_date, presence: true
  validates :to_date, presence: true

  before_create :set_statement_number, :set_charges

  scope :query, ->(keyword) { where('sales_statements.statement_number ILIKE :keyword', {keyword: "%#{keyword}%"}) }

  monetize :total_sales_cents
  monetize :total_delivery_fee_cents
  monetize :total_discount_cents
  monetize :total_redeemed_coin_cents
  monetize :total_gross_profit_cents

  mount_uploader :file, PdfUploader

  def orders
    from_time = self.from_date.beginning_of_day
    to_time = self.to_date.end_of_day

    Order.completed.joins(:success_payment).where(success_payment: { created_at: from_time..to_time }).order("success_payment.created_at DESC")
  end

  private
    def set_statement_number
      self.statement_number ||= Time.current.beginning_of_month.strftime("%Y%m") + "-" + nanoid
    end

    def set_charges
      paid_monthly_orders = orders

      # NOTE: Add discount cents due to how order.total_price was calculated
      self.total_sales_cents =
        paid_monthly_orders.sum { |paid_monthly_order| paid_monthly_order.total_cents }

      self.total_delivery_fee_cents =
        paid_monthly_orders.sum { |paid_monthly_order| paid_monthly_order.delivery_fee_cents }

      self.total_discount_cents =
        paid_monthly_orders.sum { |paid_monthly_order| paid_monthly_order.discount_cents }

      self.total_redeemed_coin_cents =
        paid_monthly_orders.sum { |paid_monthly_order| paid_monthly_order.redeemed_coin_value_cents }

      self.total_gross_profit_cents = self.total_sales_cents              -
                                      self.total_delivery_fee_cents       -
                                      self.total_redeemed_coin_cents      -
                                      self.total_discount_cents
    end
end
