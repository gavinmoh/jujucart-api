class Api::V1::User::OrdersController < Api::V1::User::ApplicationController
  before_action :set_order, only: [:show, :update, :destroy, :pack, :ship, :complete, :void, :checkout, :versions, :apply_coupon, :remove_coupon]
  before_action :set_orders, only: [:index]
  
  def index
    unless params[:skip_pagination].present? and ActiveModel::Type::Boolean.new.cast(params[:skip_pagination])
      @pagy, @orders = pagy(@orders)
    end
    render json: @orders, adapter: :json, include: index_included_associations
  end

  def show
    render json: @order, adapter: :json, include: included_associations
  end

  def create
    @order = pundit_scope(Order).new(create_params)
    @order.order_type = 'pos'
    @order.created_by = current_user
    @order.workspace = current_workspace
    pundit_authorize(@order)
    
    if @order.save
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def update
    if @order.pending? && @order.pos?
      allowed_params = pos_order_params
    else
      allowed_params = update_params
    end

    if @order.update(allowed_params)
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def checkout
    if params[:order].present?
      @order.assign_attributes(checkout_params)
    end
    
    if @order.pos_checkout!
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def complete
    begin
      ActiveRecord::Base.transaction do
        if @order.pos?
          if params[:order].present?
            payment_params = complete_params.merge(payment_type: 'cash')
          else
            payment_params = { payment_type: 'cash' }
          end
          @payment = @order.payments.create(payment_params)
          @payment.mark_as_success!
        end
        @order.complete!
        raise "can't be completed" unless @order.completed?
      end
    rescue => exception
      @order.errors.add(:base, exception.message)
    end

    if @order.completed?
      @order.reload
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def void
    if @order.void!
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def pack
    if @order.pack!
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def ship
    @order.assign_attributes(ship_params) if params[:order].present?
    if @order.ship!
      render json: @order, adapter: :json, include: included_associations
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

  def versions
    @versions = @order.versions
    render json: { versions: @versions }, status: :ok
  end

  def apply_coupon
    @coupon = Coupon.active.find_by!(code: coupon_code_params.upcase)
    @order_coupon = OrderCoupon.find_or_initialize_by(order: @order)
    @order_coupon.coupon = @coupon
    @order_coupon.code = coupon_code_params
    if @order_coupon.save!
      @order.reload
      render json: @order, adapter: :json, include: included_associations
    else
      ErrorResponse.new(@order_coupon)
    end
  end

  def remove_coupon
    if params[:code].present?
      @order_coupon = @order.order_coupon.find_by!(code: coupon_code_params)
      @order_coupon.destroy
      @order.reload
      render json: @order, adapter: :json, include: included_associations
    else
      OrderCoupon.where(order: @order).destroy_all
      @order.reload
      render json: @order, adapter: :json, include: included_associations
    end
  end

  private
    def set_order
      @order = pundit_scope(Order).includes(:customer, :created_by, :store, :order_coupon, {line_items: :product}).find(params[:id])
      pundit_authorize(@order) if @order
    end

    def set_orders
      pundit_authorize(Order)      
      @orders = pundit_scope(Order.where.not(status: 'pending')).includes(:customer, :success_payment, :created_by, :store, :order_coupon, {line_items: :product})
      @orders = status_scopable(@orders)
      @orders = keyword_queryable(@orders)
      @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
      @orders = @orders.where(customer_id: params[:customer_id]) if params[:customer_id].present?
      @orders = @orders.where(is_flagged: ActiveModel::Type::Boolean.new.cast(params[:is_flagged])) if params[:is_flagged].present?
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      @orders = @orders.where(id: params[:ids]) if params[:ids].present?
      @orders = attribute_date_scopable(@orders)
      @orders = attribute_sortable(@orders)
    end

    def index_included_associations
      ['customer', 'created_by', 'store', 'line_items.product', 'order_coupon', 'success_payment']
    end

    def included_associations
      ['customer', 'created_by', 'store', 'line_items.product', 'order_coupon', 'success_payment', 'payments', 'order_attachments']
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::OrderPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::OrderPolicy)
    end

    def pundit_permitted_attributes_for(record)
      Api::V1::User::OrderPolicy.new(pundit_user, record).permitted_attributes
    end

    def create_params
      params.require(:order).permit(:customer_id, :store_id)
    end

    def update_params
      params.require(:order).permit(
        :is_is_flagged, :is_flagged_reason, :unit_number, :street_address1, :street_address2, 
        :postcode, :city, :state, :latitude, :longitude, :courier_name, :tracking_number,
        order_attachments_attributes: [:id, :name, :file, :_destroy]
      )
    end

    def pos_order_params
      params.require(:order).permit(:customer_id, :redeemed_coin, order_attachments_attributes: [:id, :name, :file, :_destroy])
    end

    def checkout_params
      params.require(:order).permit(:customer_id)
    end

    def ship_params
      params.require(:order).permit(:courier_name, :tracking_number)
    end

    def complete_params
      params.require(:order).permit(:transaction_reference)
    end

    def coupon_code_params
      params.require(:code)
    end
end
