class Api::V1::Stripe::ApplicationController < ApplicationController
  include CallbackLoggable
  include PaymentRedirectable
  before_action { |_controller| @callback_from = 'Stripe' }
  before_action :set_payment, only: [:return]

  def callback
    head :ok
  end

  def return
    @redirect_url = case params[:status]
                    when 'cancel'
                      handle_cancel
                    else
                      handle_return
                    end

    @redirect_url ||= unknown_url
    redirect_to @redirect_url, allow_other_host: true
  end

  private

    def set_payment
      @payment = Payment.stripe.find(params[:payment_id])
    end

    def handle_cancel
      @payment.mark_as_cancelled!
      cancel_url
    end

    def handle_return
      checkout_session = Stripe::Checkout::Session.retrieve(@payment.transaction_reference)
      @payment.stripe = checkout_session

      if checkout_session.payment_status == 'paid'
        @payment.mark_as_success!
        return success_url
      end

      if checkout_session.status == 'expired'
        @payment.mark_as_failed!
        return fail_url
      end

      if checkout_session.status == 'completed' && checkout_session.payment_status == 'unpaid'
        @payment.mark_as_failed!
        return fail_url
      end

      @payment.mark_as_unknown!
      unknown_url
    end
end
