class Api::V1::User::PaymentsController < Api::V1::User::ApplicationController
  before_action :set_payment, only: [:show, :update, :destroy]
  before_action :set_payments, only: [:index]
  
  def index
    @pagy, @payments = pagy(@payments)
    render json: @payments, adapter: :json
  end

  def show
    render json: @payment, adapter: :json
  end

  private
    def set_payment
      @payment = pundit_scope(Payment).find(params[:id])
      pundit_authorize(@payment) if @payment
    end

    def set_payments
      pundit_authorize(Payment)      
      @payments = pundit_scope(Payment.includes(:order))
      @payments = @payments.where(order_id: params[:order_id]) if params[:order_id].present?
      @payments = @payments.where(payment_type: params[:payment_type]) if params[:payment_type].present?
      @payments = attribute_date_scopable(@payments)
      @payments = attribute_sortable(@payments)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::PaymentPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::PaymentPolicy)
    end
end
