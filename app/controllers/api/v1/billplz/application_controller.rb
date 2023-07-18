class Api::V1::Billplz::ApplicationController < ApplicationController
  before_action :set_payment

  def return
    extracted = extract_params
    x_signature = params[:billplz][:x_signature]

    unless verify_signature(extracted, x_signature)
      render json: { error: 'Invalid signature' }, status: :unprocessable_entity
      return
    end

    BillplzReconcilationWorker.perform_async(@payment.id)
    redirect_url = if extracted[:billplz][:paid] == 'true' && extracted[:billplz][:transaction_status] == 'completed'
                     @payment.mark_as_success! if @payment.may_mark_as_success?
                     URI.parse("#{redirect_host}/order/payment_success?order_id=#{@payment.order_id}").to_s
                   elsif extracted[:billplz][:transaction_status] == 'failed'
                     URI.parse("#{redirect_host}/order/payment_fail?order_id=#{@payment.order_id}").to_s
                   else
                     URI.parse("#{redirect_host}/order/payment_unknown?order_id=#{@payment.order_id}").to_s
                   end

    redirect_to(redirect_url, allow_other_host: true)
  end

  def callback
    extracted = extract_params
    x_signature = params[:x_signature]

    unless verify_signature(extracted, x_signature)
      render json: { error: 'Invalid signature' }, status: :unprocessable_entity
      return
    end

    extracted.each do |key, value|
      @payment.billplz[key] = value
    end
    @payment.reconciled_at = Time.current
    @payment.save
    @payment.mark_as_success! if extracted[:paid] && extracted[:transaction_status] == 'completed' && @payment.may_mark_as_success?
    head :ok
  end

  private

    def set_payment
      # jujucart_payment_id is intentional to prevent conflict with params from billplz
      @payment = Payment.find(params[:jujucart_payment_id])
    end

    def extract_params
      params.permit!.except(*request.path_parameters.keys).except(:application)
    end

    def verify_signature(payload, signature)
      Billplz::Signature.verify(payload, signature)
    end

    def redirect_host
      if @payment.created_source == @payment.order.store.hostname
        @payment.order.store.hostname
      else
        "#{@payment.order.store.subdomain}.#{Setting.main_domain}"
      end
    end
end
