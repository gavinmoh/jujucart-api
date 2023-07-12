class Api::V1::Storefront::OrdersController < Api::V1::Storefront::ApplicationController
  before_action :authenticate_customer!, only: [:index, :complete]
  before_action :set_order, only: [:show, :update, :destroy, :complete, :checkout, :apply_coupon, :remove_coupon]
  before_action :set_orders, only: [:index]

  def index
    @pagy, @orders = pagy(@orders)
    render json: @orders, adapter: :json, include: ['line_items.product', 'order_coupon', 'success_payment']
  end

  def show
    render json: @order, adapter: :json, include: ['*', 'line_items.product']
  end

  def create
    @order = Order.new(create_params)
    @order.store = current_store
    @order.customer = current_customer
    @order.created_by = current_customer
    @order.workspace = current_workspace
    pundit_authorize(@order)

    if @order.save
      render json: @order, adapter: :json
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def update
    if @order.update(update_params)
      render json: @order, adapter: :json
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def checkout
    @order.customer = current_customer if @order.customer.blank?
    @order.created_by = current_customer if @order.created_by.blank?

    if @order.checkout!
      render json: @order, adapter: :json
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def complete
    if @order.completed? || @order.complete!
      render json: @order, adapter: :json
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def apply_coupon
    @coupon = Coupon.active.find_by!(code: coupon_code_params.upcase)
    @order_coupon = OrderCoupon.find_or_initialize_by(order: @order)
    @order_coupon.coupon = @coupon
    @order_coupon.code = coupon_code_params
    if @order_coupon.save!
      @order.reload
      render json: @order, adapter: :json
    else
      ErrorResponse.new(@order_coupon)
    end
  end

  def remove_coupon
    if params[:code].present?
      @order_coupon = @order.order_coupon.find_by!(code: coupon_code_params)
      @order_coupon.destroy
    else
      OrderCoupon.where(order: @order).destroy_all
    end
    @order.reload
    render json: @order, adapter: :json
  end

  private

    def set_order
      @order = Order.where(workspace_id: current_workspace.id).find(params[:id])
      pundit_authorize(@order) if @order
    end

    def set_orders
      pundit_authorize(Order)
      @orders = pundit_scope(Order.includes({ line_items: :product }, :order_coupon, :success_payment))
      @orders = status_scopable(@orders)
      @orders = keyword_queryable(@orders)
      @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      @orders = attribute_date_scopable(@orders)
      @orders = attribute_sortable(@orders)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Storefront::OrderPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Storefront::OrderPolicy)
    end

    def create_params
      params.require(:order).permit(:order_type)
    end

    def update_params
      params.require(:order).permit(
        :unit_number, :street_address1, :street_address2,
        :postcode, :city, :state, :latitude, :longitude,
        order_attachments_attributes: [:id, :name, :file, :_destroy]
      )
    end

    def coupon_code_params
      params.require(:code)
    end
end