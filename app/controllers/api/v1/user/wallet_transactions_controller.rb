class Api::V1::User::WalletTransactionsController < Api::V1::User::ApplicationController
  before_action :set_wallet
  before_action :set_wallet_transaction, only: [:show]
  before_action :set_wallet_transactions, only: [:index]
  
  def index
    @pagy, @wallet_transactions = pagy(@wallet_transactions)
    render json: @wallet_transactions, adapter: :json
  end

  def show
    render json: @wallet_transaction, adapter: :json
  end

  private
    def set_wallet
      @wallet = policy_scope(Wallet.all, policy_scope_class: Api::V1::User::WalletPolicy::Scope).find(params[:wallet_id])
    end

    def set_wallet_transaction
      @wallet_transaction = @wallet.wallet_transactions.find(params[:id])
    end

    def set_wallet_transactions     
      @wallet_transactions = @wallet.wallet_transactions.includes(:wallet, :order)
      @wallet_transactions = attribute_sortable(@wallet_transactions)
    end
end
