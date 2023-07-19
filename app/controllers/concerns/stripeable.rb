module Stripeable
  extend ActiveSupport::Concern

  def create_stripe_payment(order)
    return if order.pending_stripe_payment.present?

    uuid = SecureRandom.uuid
    checkout_session = create_stripe_checkout_session(order, uuid)
    order.payments.create(
      id: uuid,
      payment_type: :online,
      service_provider: 'Stripe',
      transaction_reference: checkout_session.id,
      stripe: checkout_session,
      created_source: request.host
    )
  end

  def create_stripe_checkout_session(order, payment_id)
    payload = {
      mode: 'payment',
      client_reference_id: payment_id,
      success_url: api_v1_stripe_return_url(payment_id, status: 'success'),
      cancel_url: api_v1_stripe_return_url(payment_id, status: 'cancel'),
      line_items: [
        {
          price_data: {
            currency: order.total.currency,
            unit_amount: order.total.cents,
            product_data: {
              name: "Order ##{order.nanoid} at #{current_store.name}"
            }
          },
          quantity: 1
        }
      ],
      payment_intent_data: {
        metadata: {
          order_id: order.id
        },
        transfer_data: {
          destination: current_workspace.stripe_account_id
        },
        application_fee_amount: (order.total * 0.05).cents
      }
    }

    if order.customer.present?
      payload[:customer] = find_or_create_stripe_customer_id(order)
    else
      payload[:customer_email] = order.customer_email
    end

    Stripe::Checkout::Session.create(payload)
  end

  def find_or_create_stripe_customer_id(order)
    return nil if order.customer.blank?

    order.customer.stripe_customer_id || create_stripe_customer(customer).id
  end

  def create_stripe_customer(customer)
    stripe_customer = Stripe::Customer.create(
      email: customer.email,
      name: customer.name,
      phone: customer.phone_number
    )
    customer.update(stripe_customer_id: customer.id)
    stripe_customer
  end
end
