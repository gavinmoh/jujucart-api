class Api::V1::User::WalletsController < Api::V1::User::ApplicationController
  before_action :set_wallet, only: [:show]
  before_action :set_wallets, only: [:index]
  
  def index
    @pagy, @wallets = pagy(@wallets)
    render json: @wallets, adapter: :json
  end

  def show
    render json: @wallet, adapter: :json
  end

  private
    def set_wallet
      @wallet = pundit_scope(Wallet).find(params[:id])
      pundit_authorize(@wallet) if @wallet
    end

    def set_wallets
      pundit_authorize(Wallet)      
      @wallets = pundit_scope(Wallet.includes(:customer))
      @wallets = attribute_sortable(@wallets)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::WalletPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::WalletPolicy)
    end
end
