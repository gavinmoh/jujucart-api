class Api::V1::User::InventoryTransfersController < Api::V1::User::ApplicationController
  before_action :set_inventory_transfer, only: [:show, :update, :destroy, :transfer, :accept, :cancel, :revert]
  before_action :set_inventory_transfers, only: [:index]
  
  def index
    @pagy, @inventory_transfers = pagy(@inventory_transfers)
    render json: @inventory_transfers, adapter: :json, include: index_included_associations
  end

  def show
    render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
  end

  def create
    @inventory_transfer = pundit_scope(InventoryTransfer).new(inventory_transfer_params)
    @inventory_transfer.created_by = current_user
    pundit_authorize(@inventory_transfer)

    if @inventory_transfer.save
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def update
    if @inventory_transfer.update(inventory_transfer_params)
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def destroy
    if @inventory_transfer.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def transfer
    @inventory_transfer.transferred_by = current_user
    if @inventory_transfer.transferred? or @inventory_transfer.transfer!
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def accept
    @inventory_transfer.assign_attributes(accept_params)
    @inventory_transfer.accepted_by = current_user
    if @inventory_transfer.accepted? or @inventory_transfer.accept!
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def cancel
    @inventory_transfer.cancelled_by = current_user
    if @inventory_transfer.cancelled? or @inventory_transfer.cancel!
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  def revert
    @inventory_transfer.reverted_by = current_user
    if @inventory_transfer.reverted? or @inventory_transfer.revert!
      render json: @inventory_transfer, adapter: :json, include: ['*', 'transfer_from_location.store', 'transfer_to_location.store', 'inventory_transfer_items.product']
    else
      render json: ErrorResponse.new(@inventory_transfer), status: :unprocessable_entity
    end
  end

  private
    def set_inventory_transfer
      @inventory_transfer = pundit_scope(InventoryTransfer.includes({inventory_transfer_items: :product})).find(params[:id])
      pundit_authorize(@inventory_transfer) if @inventory_transfer
    end

    def set_inventory_transfers
      pundit_authorize(InventoryTransfer)      
      @inventory_transfers = pundit_scope(InventoryTransfer.includes({transfer_from_location: :store}, {transfer_to_location: :store}, :created_by, :transferred_by, :accepted_by, :cancelled_by, :reverted_by))
      @inventory_transfers = @inventory_transfers.where(transfer_from_location_id: params[:transfer_from_location_id]) if params[:transfer_from_location_id]
      @inventory_transfers = @inventory_transfers.where(transfer_to_location_id: params[:transfer_to_location_id]) if params[:transfer_to_location_id]
      @inventory_transfers = status_scopable(@inventory_transfers)
      @inventory_transfers = attribute_sortable(@inventory_transfers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::InventoryTransferPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::InventoryTransferPolicy)
    end

    def inventory_transfer_params
      params.require(:inventory_transfer).permit(
        :transfer_from_location_id, :transfer_to_location_id, :remark,
        inventory_transfer_items_attributes: [:id, :product_id, :quantity, :_destroy]
      )
    end

    def accept_params
      params.require(:inventory_transfer).permit(:acceptance_remark)
    end

    def index_included_associations
      [ 'created_by', 'transferred_by', 'accepted_by', 'cancelled_by', 'reverted_by',
         'transfer_from_location.store', 'transfer_to_location.store']
    end
end
