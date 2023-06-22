class Api::V1::User::InventoryTransactionsController < Api::V1::User::ApplicationController
  before_action :set_inventory_transaction, only: [:show, :update, :destroy]
  before_action :set_inventory_transactions, only: [:index]
  
  def index
    @pagy, @inventory_transactions = pagy(@inventory_transactions)
    render json: @inventory_transactions, adapter: :json, include: ['inventory.location.store', 'inventory.product']
  end

  def show
    render json: @inventory_transaction, adapter: :json, include: ['inventory.location.store', 'inventory.product', 'order']
  end

  def create
    @inventory_transaction = InventoryTransaction.new(inventory_transaction_params)
    pundit_authorize(@inventory_transaction)

    if @inventory_transaction.save
      render json: @inventory_transaction, adapter: :json, include: ['inventory.location.store', 'inventory.product', 'order']
    else
      render json: ErrorResponse.new(@inventory_transaction), status: :unprocessable_entity
    end
  end

  def update
    if @inventory_transaction.update(inventory_transaction_params)
      render json: @inventory_transaction, adapter: :json, include: ['inventory.location.store', 'inventory.product', 'order']
    else
      render json: ErrorResponse.new(@inventory_transaction), status: :unprocessable_entity
    end
  end

  def destroy
    if @inventory_transaction.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@inventory_transaction), status: :unprocessable_entity
    end
  end

  def adjustment
    @inventory = Inventory.find_or_create_by(adjustment_params.slice(:location_id, :product_id).merge(workspace_id: current_workspace.id))
    @inventory_transaction = @inventory.inventory_transactions.new(adjustment_params.slice(:quantity, :description))
    pundit_authorize(@inventory_transaction)

    if @inventory_transaction.save
      render json: @inventory_transaction, adapter: :json, include: ['inventory.location.store', 'inventory.product', 'order']
    else
      render json: ErrorResponse.new(@inventory_transaction), status: :unprocessable_entity
    end
  end

  private
    def set_inventory_transaction
      @inventory_transaction = pundit_scope(InventoryTransaction).find(params[:id])
      pundit_authorize(@inventory_transaction) if @inventory_transaction
    end

    def set_inventory_transactions
      pundit_authorize(InventoryTransaction)      
      @inventory_transactions = pundit_scope(InventoryTransaction.includes({inventory: [:product, {location: :store}]}))
      @inventory_transactions = @inventory_transactions.where(inventory_id: params[:inventory_id]) if params[:inventory_id].present?
      @inventory_transactions = @inventory_transactions.joins(:inventory).where(inventory: {location_id: params[:location_id]}) if params[:location_id].present?
      @inventory_transactions = attribute_sortable(@inventory_transactions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::InventoryTransactionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::InventoryTransactionPolicy)
    end

    def inventory_transaction_params
      params.require(:inventory_transaction).permit(:inventory_id, :quantity, :description)
    end

    def adjustment_params
      params.require(:inventory_transaction).permit(:location_id, :product_id, :quantity, :description)
    end
end
