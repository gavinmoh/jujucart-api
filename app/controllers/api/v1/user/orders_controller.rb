class Api::V1::User::OrdersController < Api::V1::User::ApplicationController
  before_action :set_order, only: [:show, :update, :destroy, :confirm, :pack, :ship, :complete, :void, :checkout, :versions, :apply_coupon, :remove_coupon]
  before_action :set_orders, only: [:index]
  before_action :set_bulk_orders, only: [:bulk_confirm, :bulk_pack, :bulk_complete, :bulk_void]

  def index
    if params[:skip_pagination].present? && ActiveModel::Type::Boolean.new.cast(params[:skip_pagination])
      # only allow filter by params[:ids] when skip_pagination is true
      @orders = @orders.where(id: params[:ids]) if params[:ids].present?
    else
      @pagy, @orders = pagy(@orders)
    end
    render json: @orders, adapter: :json, include: index_included_associations
  end

  def show
    render json: @order, adapter: :json, include: included_associations
  end

  def create
    @order = Order.new(order_type: params[:order][:order_type] || 'pos')
    @order.created_by = current_user
    @order.workspace = current_workspace

    if @order.manual?
      @order.assign_attributes(manual_order_params)
    else
      @order.assign_attributes(create_params)
    end
    pundit_authorize(@order)

    if @order.save
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def update
    allowed_params = if @order.pending? && @order.pos?
                       pos_order_params
                     elsif @order.manual?
                       manual_order_params
                     else
                       update_params
                     end

    if @order.update(allowed_params)
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def checkout
    @order.assign_attributes(checkout_params) if params[:order].present?

    if @order.pos_checkout!
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def confirm
    if @order.confirmed? || @order.confirm!
      render json: @order, adapter: :json, include: included_associations
    else
      render json: ErrorResponse.new(@order), status: :unprocessable_entity
    end
  end

  def complete
    begin
      ActiveRecord::Base.transaction do
        if @order.pos?
          payment_params = if params[:order].present?
                             complete_params.merge(payment_type: 'cash')
                           else
                             { payment_type: 'cash' }
                           end
          @payment = @order.payments.create(payment_params)
          @payment.mark_as_success!
        end
        @order.complete!
        raise "can't be completed" unless @order.completed?
      end
    rescue StandardError => e
      @order.errors.add(:base, e.message)
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
    else
      OrderCoupon.where(order: @order).destroy_all
    end
    @order.reload
    render json: @order, adapter: :json, include: included_associations
  end

  def bulk_confirm
    success, error_object, error = bulk_status_action(@orders, :confirm!)
    if success
      @orders.reload
      render json: @orders, adapter: :json, include: index_included_associations
    elsif error_object&.errors
      render json: ErrorResponse.new(error_object), status: :unprocessable_entity
    else
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  def bulk_pack
    success, error_object, error = bulk_status_action(@orders, :pack!)
    if success
      @orders.reload
      render json: @orders, adapter: :json, include: index_included_associations
    elsif error_object&.errors
      render json: ErrorResponse.new(error_object), status: :unprocessable_entity
    else
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  def bulk_complete
    success, error_object, error = bulk_status_action(@orders, :complete!)
    if success
      @orders.reload
      render json: @orders, adapter: :json, include: index_included_associations
    elsif error_object&.errors
      render json: ErrorResponse.new(error_object), status: :unprocessable_entity
    else
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  def bulk_void
    success, error_object, error = bulk_status_action(@orders, :void!)
    if success
      @orders.reload
      render json: @orders, adapter: :json, include: index_included_associations
    elsif error_object&.errors
      render json: ErrorResponse.new(error_object), status: :unprocessable_entity
    else
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  private

    def set_order
      @order = pundit_scope(Order).includes(:customer, :created_by, :store, :order_coupon, { line_items: :product }).find(params[:id])
      pundit_authorize(@order) if @order
    end

    def set_orders
      pundit_authorize(Order)
      @orders = pundit_scope(Order.include_pending_manual_order).includes(:customer, :success_payment, :created_by, :store, :order_coupon, { line_items: :product })
      @orders = status_scopable(@orders)
      @orders = keyword_queryable(@orders)
      @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
      @orders = @orders.where(customer_id: params[:customer_id]) if params[:customer_id].present?
      @orders = @orders.where(is_flagged: ActiveModel::Type::Boolean.new.cast(params[:is_flagged])) if params[:is_flagged].present?
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      @orders = attribute_date_scopable(@orders)
      @orders = attribute_sortable(@orders)
    end

    def set_bulk_orders
      pundit_authorize(Order)
      @orders = pundit_scope(Order).includes(:customer, :workspace, :success_payment, :created_by, :order_coupon, { store: :location }, { line_items: :product })
      @orders = @orders.where(id: bulk_order_ids_params)
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
      params.require(:order).permit(:customer_id, :store_id, :order_type)
    end

    def manual_order_params
      params.require(:order).permit(
        :customer_id, :store_id, :is_flagged, :flagged_reason, :courier_name, :tracking_number, :order_type,
        :billing_address_unit_number, :billing_address_street_address1, :billing_address_street_address2,
        :billing_address_postcode, :billing_address_city, :billing_address_state, :billing_address_country,
        :billing_address_latitude, :billing_address_longitude, :billing_address_contact_name,
        :billing_address_contact_email, :billing_address_contact_phone_number,
        :delivery_address_unit_number, :delivery_address_street_address1, :delivery_address_street_address2,
        :delivery_address_postcode, :delivery_address_city, :delivery_address_state, :delivery_address_country,
        :delivery_address_latitude, :delivery_address_longitude, :delivery_address_contact_name,
        :delivery_address_contact_email, :delivery_address_contact_phone_number,
        line_items_attributes: [:id, :product_id, :quantity, :name, :unit_price, :_destroy],
        order_attachments_attributes: [:id, :name, :file, :_destroy]
      )
    end

    def update_params
      params.require(:order).permit(
        :is_flagged, :flagged_reason, :courier_name, :tracking_number,
        :billing_address_unit_number, :billing_address_street_address1, :billing_address_street_address2,
        :billing_address_postcode, :billing_address_city, :billing_address_state, :billing_address_country,
        :billing_address_latitude, :billing_address_longitude, :billing_address_contact_name,
        :billing_address_contact_email, :billing_address_contact_phone_number,
        :delivery_address_unit_number, :delivery_address_street_address1, :delivery_address_street_address2,
        :delivery_address_postcode, :delivery_address_city, :delivery_address_state, :delivery_address_country,
        :delivery_address_latitude, :delivery_address_longitude, :delivery_address_contact_name,
        :delivery_address_contact_email, :delivery_address_contact_phone_number,
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

    def bulk_order_ids_params
      params.require(:ids)
    end

    def bulk_status_action(records, event)
      current_record = nil
      ActiveRecord::Base.transaction do
        records.find_each do |record|
          current_record = record
          raise unless record.send(event)
        end
      end
      [true, nil, nil]
    rescue StandardError => e
      current_record.errors.add(:status, "cannot transition from #{current_record.status}") unless current_record.errors.any?
      [false, current_record, e]
    end
end
