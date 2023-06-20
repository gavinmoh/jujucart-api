class Api::V1::User::PosTerminalsController < Api::V1::User::ApplicationController
  before_action :set_pos_terminal, only: [:show, :update, :destroy, :initiate_payment, :cancel_payment, :card_payment_refund]
  before_action :set_pos_terminals, only: [:index]
  before_action :set_order, only: [:initiate_payment]
  before_action :set_payment, only: [:card_payment_refund]
  
  def index
    @pagy, @pos_terminals = pagy(@pos_terminals)
    render json: @pos_terminals, adapter: :json
  end

  def show
    render json: @pos_terminal, adapter: :json
  end

  def create
    @pos_terminal = pundit_scope(PosTerminal).new(pos_terminal_params)
    pundit_authorize(@pos_terminal)
    
    if @pos_terminal.save
      render json: @pos_terminal, adapter: :json
    else
      render json: ErrorResponse.new(@pos_terminal), status: :unprocessable_entity
    end
  end

  def update
    if @pos_terminal.update(pos_terminal_params)
      render json: @pos_terminal, adapter: :json
    else
      render json: ErrorResponse.new(@pos_terminal), status: :unprocessable_entity
    end
  end

  def destroy
    if @pos_terminal.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@pos_terminal), status: :unprocessable_entity
    end
  end

  def initiate_payment
    @payment = @order.payments.create(payment_type: 'terminal', payment_method: initiate_payment_params[:type], terminal_id: @pos_terminal.terminal_id, amount: @order.total)
    @rm_order = RevenueMonster::Order.new(
      id: @payment.nanoid,
      amount: @payment.amount_cents,
      title: @order.nanoid,
      details: @order.nanoid,
      additional_data: @order.id
    )
    response = RevenueMonster::Terminal.initiate_payment(terminal_id: @pos_terminal.terminal_id, type: initiate_payment_params[:type], order: @rm_order)
    @payment.update(
      revenue_monster: response,
      transaction_reference: response['transactionId']
    )
    case response['status']
    when 'SUCCESS'
      @payment.mark_as_success!
    when 'FAILED'
      @payment.mark_as_failed!
    else
      @payment.mark_as_unknown!
    end
    render json: @payment, adapter: :json
  rescue RevenueMonster::RequestError, RevenueMonster::RequestTimeoutError, RevenueMonster::TerminalNotReachableError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def cancel_payment
    response = RevenueMonster::Terminal.cancel_payment(terminal_id: @pos_terminal.terminal_id)
    render json: response, status: :ok
  rescue RevenueMonster::RequestError, RevenueMonster::RequestTimeoutError, RevenueMonster::TerminalNotReachableError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def card_payment_refund
    email = @payment.order.customer&.email || card_payment_refund_params[:email]

    unless email
      @payment.errors.add(:refund_email, "is required")
      render json: ErrorResponse.new(@payment), status: :unprocessable_entity and return
    end

    response = RevenueMonster::Terminal.card_payment_refund(
      terminal_id: @pos_terminal.terminal_id,
      transaction_id: @payment.transaction_reference,
      reason: card_payment_refund_params[:reason],
      email: email,
      pin: card_payment_refund_params[:pin]
    )

    if response['code'] == 'SUCCESS'
      @payment.update(revenue_monster: response)
      @payment.refund! if @payment.may_refund?
      render json: @payment, adapter: :json
    else
      render json: response, status: :unprocessable_entity
    end
  rescue RevenueMonster::RequestError, RevenueMonster::RequestTimeoutError, RevenueMonster::TerminalNotReachableError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    def set_pos_terminal
      @pos_terminal = pundit_scope(PosTerminal).find(params[:id])
      pundit_authorize(@pos_terminal) if @pos_terminal
    end

    def set_pos_terminals
      pundit_authorize(PosTerminal)      
      @pos_terminals = pundit_scope(PosTerminal.includes(:store))
      @pos_terminals = @pos_terminals.where(store_id: params[:store_id]) if params[:store_id].present?
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::PosTerminalPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::PosTerminalPolicy)
    end

    def pos_terminal_params
      params.require(:pos_terminal).permit(:store_id, :terminal_id, :label)
    end

    def set_order
      @order = policy_scope(Order, policy_scope_class: Api::V1::User::OrderPolicy::Scope).pos.pending_payment.find(initiate_payment_params[:order_id])
    end

    def set_payment
      @payment = policy_scope(Payment, policy_scope_class: Api::V1::User::PaymentPolicy::Scope).find(card_payment_refund_params[:id])
    end

    def initiate_payment_params
      params.require(:payment).permit(:order_id, :type)
    end

    def card_payment_refund_params
      params.require(:payment).permit(:id, :reason, :email, :pin)
    end
end
