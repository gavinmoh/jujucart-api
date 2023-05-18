class Api::V1::User::PromotionBundlesController < Api::V1::User::ApplicationController
  before_action :set_promotion_bundle, only: [:show, :update, :destroy]
  before_action :set_promotion_bundles, only: [:index]
  
  def index
    @pagy, @promotion_bundles = pagy(@promotion_bundles)
    render json: @promotion_bundles, adapter: :json
  end

  def show
    render json: @promotion_bundle, adapter: :json
  end

  def create
    @promotion_bundle = pundit_scope(PromotionBundle).new(promotion_bundle_params)
    pundit_authorize(@promotion_bundle)

    if @promotion_bundle.save
      render json: @promotion_bundle, adapter: :json
    else
      render json: ErrorResponse.new(@promotion_bundle), status: :unprocessable_entity
    end
  end

  def update
    if @promotion_bundle.update(promotion_bundle_params)
      render json: @promotion_bundle, adapter: :json
    else
      render json: ErrorResponse.new(@promotion_bundle), status: :unprocessable_entity
    end
  end

  def destroy
    if @promotion_bundle.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@promotion_bundle), status: :unprocessable_entity
    end
  end

  private
    def set_promotion_bundle
      @promotion_bundle = pundit_scope(PromotionBundle).find(params[:id])
      pundit_authorize(@promotion_bundle) if @promotion_bundle
    end

    def set_promotion_bundles
      pundit_authorize(PromotionBundle)      
      @promotion_bundles = pundit_scope(PromotionBundle.includes(:promotion_bundle_items))
      @promotion_bundles = @promotion_bundles.where(promotion_bundle_items: { product_id: params[:product_id] }) if params[:product_id].present?
      if params[:scope].present?
        case params[:scope]
        when 'active'
          @promotion_bundles = @promotion_bundles.active
        when 'expired'
          @promotion_bundles = @promotion_bundles.expired
        when 'scheduled'
          @promotion_bundles = @promotion_bundles.scheduled
        end
      end
      @promotion_bundles = attribute_sortable(@promotion_bundles)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::PromotionBundlePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::PromotionBundlePolicy)
    end

    def promotion_bundle_params
      params.require(:promotion_bundle).permit(
        :name, :discount_by, :discount_price, :discount_percentage, :start_at, :end_at, :active,
        promotion_bundle_items_attributes: [:id, :product_id, :quantity, :_destroy]
      )
    end
end
