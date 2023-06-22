class Api::V1::User::CouponsController < Api::V1::User::ApplicationController
  before_action :set_coupon, only: [:show, :update, :destroy]
  before_action :set_coupons, only: [:index]
  
  def index
    @pagy, @coupons = pagy(@coupons)
    render json: @coupons, adapter: :json, include_total_redemptions: true
  end

  def show
    render json: @coupon, adapter: :json, include_total_redemptions: true
  end

  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.workspace = current_workspace
    pundit_authorize(@coupon)

    if @coupon.save
      render json: @coupon, adapter: :json, include_total_redemptions: true
    else
      render json: ErrorResponse.new(@coupon), status: :unprocessable_entity
    end
  end

  def update
    if @coupon.update(coupon_params)
      render json: @coupon, adapter: :json, include_total_redemptions: true
    else
      render json: ErrorResponse.new(@coupon), status: :unprocessable_entity
    end
  end

  def destroy
    if @coupon.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@coupon), status: :unprocessable_entity
    end
  end

  private
    def set_coupon
      @coupon = pundit_scope(Coupon).find(params[:id])
      pundit_authorize(@coupon) if @coupon
    end

    def set_coupons
      pundit_authorize(Coupon)      
      @coupons = pundit_scope(Coupon.with_total_redemptions.all)
      if params[:scope].present?
        case params[:scope]
        when 'active'
          @coupons = @coupons.active
        when 'expired'
          @coupons = @coupons.expired
        when 'scheduled'
          @coupons = @coupons.scheduled
        end
      end
      @coupons = attribute_sortable(@coupons)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::CouponPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::CouponPolicy)
    end

    def coupon_params
      params.require(:coupon).permit(
        :name, :code, :redemption_limit, :start_at, :end_at, :discount_by, :discount_price, 
        :discount_percentage, :minimum_spend, :maximum_cap, :coupon_type, :discount_on,
        order_types: []
      )
    end
end
