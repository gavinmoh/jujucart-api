class Api::V1::Admin::WorkspacesController < Api::V1::Admin::ApplicationController
  before_action :set_workspace, only: [:show, :update, :destroy]
  before_action :set_workspaces, only: [:index]
  
  def index
    @pagy, @workspaces = pagy(@workspaces)
    render json: @workspaces, adapter: :json
  end

  def show
    render json: @workspace, adapter: :json
  end

  def create
    @workspace = pundit_scope(Workspace).new(workspace_params)
    @workspace.created_by_id = current_admin.id
    pundit_authorize(@workspace)

    if @workspace.save
      render json: @workspace, adapter: :json
    else
      render json: ErrorResponse.new(@workspace), status: :unprocessable_entity
    end
  end

  def update
    if @workspace.update(workspace_params)
      render json: @workspace, adapter: :json
    else
      render json: ErrorResponse.new(@workspace), status: :unprocessable_entity
    end
  end

  def destroy
    if @workspace.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@workspace), status: :unprocessable_entity
    end
  end

  private
    def set_workspace
      @workspace = pundit_scope(Workspace).find(params[:id])
      pundit_authorize(@workspace) if @workspace
    end

    def set_workspaces
      pundit_authorize(Workspace)      
      @workspaces = pundit_scope(Workspace.includes(:owner, :created_by))
      @workspaces = attribute_sortable(@workspaces)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::WorkspacePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::WorkspacePolicy)
    end

    def workspace_params
      params.require(:workspace).permit(
        :name, :logo, :subdomain, :owner_id, :web_host, :coin_to_cash_rate, :order_reward_amount, 
        :maximum_redeemed_coin_rate, :invoice_size, :company_phone_number, :company_email, :company_name, 
        :company_address, :bank_name, :bank_account_number, :bank_holder_name, :receipt_footer
      )
    end
end
