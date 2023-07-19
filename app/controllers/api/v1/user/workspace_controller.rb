class Api::V1::User::WorkspaceController < Api::V1::User::ApplicationController
  before_action :set_workspace, only: [:show, :update]

  def show
    render json: @workspace, adapter: :json
  end

  def update
    if @workspace.update(workspace_params)
      render json: @workspace, adapter: :json
    else
      render json: ErrorResponse.new(@workspace), status: :unprocessable_entity
    end
  end

  private

    def set_workspace
      @workspace = current_workspace
      pundit_authorize(@workspace)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::WorkspacePolicy)
    end

    def workspace_params
      params.require(:workspace).permit(
        :name, :logo, :subdomain, :web_host, :coin_to_cash_rate,
        :order_reward_amount, :maximum_redeemed_coin_rate, :invoice_size, :company_phone_number,
        :company_email, :company_name, :company_address, :bank_name, :bank_account_number,
        :bank_holder_name, :receipt_footer, :default_payment_gateway
      )
    end
end
