module PaymentRedirectable
  extend ActiveSupport::Concern

  def redirect_host
    if @payment.created_source == @payment.order.store.hostname
      @payment.order.store.hostname
    else
      "#{@payment.order.store.subdomain}.#{Setting.main_domain}"
    end
  end

  def cancel_url
    URI.parse("#{redirect_host}/order/payment_cancel?order_id=#{@payment.order_id}").to_s
  end

  def fail_url
    URI.parse("#{redirect_host}/order/payment_fail?order_id=#{@payment.order_id}").to_s
  end

  def unknown_url
    URI.parse("#{redirect_host}/order/payment_unknown?order_id=#{@payment.order_id}").to_s
  end

  def success_url
    URI.parse("#{redirect_host}/order/payment_success?order_id=#{@payment.order_id}").to_s
  end
end
