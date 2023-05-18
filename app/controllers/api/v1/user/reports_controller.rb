class Api::V1::User::ReportsController < Api::V1::User::ApplicationController
  before_action :set_time_range
  before_action :set_orders, only: [:revenue, :total_paid_order]
  before_action :set_all_orders, only: [:total_order, :total_checkout, :total_abandoned]

  def revenue
    reports = []
    (@from_time.to_date..@to_time.to_date).each do |date|
      orders  = @orders.select { |order| order.pending_payment_at&.to_date == date }
      revenue = orders.inject(Money.new(0)) { |sum, order| sum + order.total }
      reports << { date: date, revenue: revenue.to_f }
    end
    render json: { total_revenue: Money.new(@orders.sum(:total_cents)), reports: reports, from_date: @from_time.to_date, to_date: @to_time.to_date }, status: :ok
  end

  def total_paid_order
    reports = []
    (@from_time.to_date..@to_time.to_date).each do |date|
      orders  = @orders.select { |order| order.pending_payment_at&.to_date == date }
      reports << { date: date, count: orders.count }
    end
    render json: { reports: reports, total_count: @orders.count, from_date: @from_time.to_date, to_date: @to_time.to_date }, status: :ok
  end

  def total_order
    reports = []
    (@from_time.to_date..@to_time.to_date).each do |date|
      orders  = @orders.select { |order| order.pending_payment_at&.to_date == date }
      reports << { date: date, count: orders.count }
    end
    render json: { reports: reports, total_count: @orders.count, from_date: @from_time.to_date, to_date: @to_time.to_date }, status: :ok
  end

  def total_checkout
    reports = []
    total_count = 0
    (@from_time.to_date..@to_time.to_date).each do |date|
      orders  = @orders.select { |order| order.pending_payment_at&.to_date == date }
      reports << { date: date, count: orders.count }
      total_count = total_count + orders.count
    end
    render json: { reports: reports, total_count: total_count, from_date: @from_time.to_date, to_date: @to_time.to_date }, status: :ok
  end

  def total_abandoned
    reports = []
    total_count = 0
    (@from_time.to_date..@to_time.to_date).each do |date|
      orders  = @orders.select { |order| order.pending_payment_at&.to_date == date && ['failed', 'pending_payment'].include?(order.status) }
      reports << { date: date, count: orders.count }
      total_count = total_count + orders.count
    end
    render json: { reports: reports, total_count: total_count, from_date: @from_time.to_date, to_date: @to_time.to_date }, status: :ok
  end

  private
    def set_time_range
      if params[:from_date].present? and params[:to_date].present?
        @from_time = Time.zone.parse(params[:from_date]).beginning_of_day
        @to_time   = Time.zone.parse(params[:to_date]).end_of_day
      end
      @from_time ||= (Time.current - 1.month).beginning_of_day
      @to_time   ||= Time.current.end_of_day
    end

    def set_orders
      @orders = Order.paid.where(pending_payment_at: @from_time..@to_time)
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
    end

    def set_all_orders
      @orders = Order.where(created_at: @from_time..@to_time)
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
    end
end
