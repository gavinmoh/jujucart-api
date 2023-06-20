class Api::V1::RevenueMonster::ApplicationController < ApplicationController
  before_action { |_controller| @callback_from = 'RevenueMonster' }
  include CallbackLoggable

  def callback
    payload = JSON.parse(request.body.read)
    transaction_id = payload.dig('item', 'transactionId')

    unless transaction_id.present?
      response_success and return
    end

    @payment = Payment.find_by(transaction_reference: transaction_id)
    unless @payment.present?
      response_success and return
    end
    
    @order = @payment.order
    status = payload.dig('item', 'status')
    @payment.update(revenue_monster: payload.dig('item'))
    @callback_processed_at = Time.now
    case status
    when 'FULL_REFUNDED'
      @payment.refund! if @payment.may_refund?
    when 'SUCCESS'
      @payment.mark_as_success! if @payment.may_mark_as_success?
    when 'FAILED'
      @payment.mark_as_failed! if @payment.may_mark_as_failed?
    else
      @payment.mark_as_unknown! if @payment.may_mark_as_unknown?      
    end
    response_success and return 
  end

  private
    def response_success
      render json: { status: 'success' }
    end

end