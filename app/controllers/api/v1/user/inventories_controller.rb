class Api::V1::User::InventoriesController < Api::V1::User::ApplicationController
  before_action :set_inventory, only: [:show, :update, :destroy]
  before_action :set_inventories, only: [:index]
  
  def index
    @pagy, @inventories = pagy(@inventories)
    render json: @inventories, adapter: :json, include: ['product', 'store']
  end

  def show
    render json: @inventory, adapter: :json, include: ['inventory_transactions']
  end

  def create
    @inventory = pundit_scope(Inventory).new(inventory_params)
    pundit_authorize(@inventory)

    if @inventory.save
      render json: @inventory, adapter: :json, include: ['inventory_transactions']
    else
      render json: ErrorResponse.new(@inventory), status: :unprocessable_entity
    end
  end

  def update
    if @inventory.update(inventory_params)
      render json: @inventory, adapter: :json, include: ['inventory_transactions']
    else
      render json: ErrorResponse.new(@inventory), status: :unprocessable_entity
    end
  end

  def destroy
    if @inventory.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@inventory), status: :unprocessable_entity
    end
  end

  private
    def set_inventory
      @inventory = pundit_scope(Inventory).find(params[:id])
      pundit_authorize(@inventory) if @inventory
    end

    def set_inventories
      pundit_authorize(Inventory)      
      @inventories = pundit_scope(Inventory.includes(:product, :store))
      @inventories = @inventories.where(store_id: params[:store_id]) if params[:store_id]
      @inventories = @inventories.where(product_id: params[:product_id]) if params[:product_id]
      @inventories = attribute_sortable(@inventories, { created_at: :desc })
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::InventoryPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::InventoryPolicy)
    end

    def inventory_params
      params.require(:inventory).permit(:store_id, :product_id)
    end
end
