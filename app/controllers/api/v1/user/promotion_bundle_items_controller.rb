class Api::V1::User::PromotionBundleItemsController < Api::V1::User::ApplicationController
  before_action :set_promotion_bundle
  before_action :set_promotion_bundle_item, only: [:show, :update, :destroy]
  before_action :set_promotion_bundle_items, only: [:index]
  
  def index
    @pagy, @promotion_bundle_items = pagy(@promotion_bundle_items)
    render json: @promotion_bundle_items, adapter: :json
  end

  def show
    render json: @promotion_bundle_item, adapter: :json
  end

  def create
    @promotion_bundle_item = pundit_scope(@promotion_bundle.promotion_bundle_items).new(promotion_bundle_item_params)
    pundit_authorize(@promotion_bundle_item)

    if @promotion_bundle_item.save
      render json: @promotion_bundle_item, adapter: :json
    else
      render json: ErrorResponse.new(@promotion_bundle_item), status: :unprocessable_entity
    end
  end

  def update
    if @promotion_bundle_item.update(promotion_bundle_item_params)
      render json: @promotion_bundle_item, adapter: :json
    else
      render json: ErrorResponse.new(@promotion_bundle_item), status: :unprocessable_entity
    end
  end

  def destroy
    if @promotion_bundle_item.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@promotion_bundle_item), status: :unprocessable_entity
    end
  end

  private
    def set_promotion_bundle
      @promotion_bundle = pundit_scope(PromotionBundle).find(params[:promotion_bundle_id])
      authorize(@promotion_bundle, policy_class: Api::V1::User::PromotionBundlePolicy) if @promotion_bundle
    end

    def set_promotion_bundle_item
      @promotion_bundle_item = pundit_scope(@promotion_bundle.promotion_bundle_items).find(params[:id])
      pundit_authorize(@promotion_bundle_item) if @promotion_bundle_item
    end

    def set_promotion_bundle_items
      pundit_authorize(PromotionBundleItem)      
      @promotion_bundle_items = pundit_scope(@promotion_bundle.promotion_bundle_items.includes(:promotion_bundle, :product))
      @promotion_bundle_items = attribute_sortable(@promotion_bundle_items)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::PromotionBundleItemPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::PromotionBundleItemPolicy)
    end

    def promotion_bundle_item_params
      params.require(:promotion_bundle_item).permit(:promotion_bundle_id, :product_id, :quantity)
    end
end
