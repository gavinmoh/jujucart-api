module Billplzable
  extend ActiveSupport::Concern

  def create_billplz_payment(order)
    return if order.pending_billplz_payment.present?

    collection = billplz_collection
    uuid = SecureRandom.uuid
    bill = create_billplz_bill(order, collection, uuid)
    order.payments.create(
      id: uuid,
      payment_type: :online,
      service_provider: 'Billplz',
      transaction_reference: bill.id,
      billplz: bill,
      created_source: request.host
    )
  end

  def billplz_collection
    if current_store.billplz_collection_id.present?
      Billplz::Collection.get(current_store.billplz_collection_id)
    else
      Billplz::Collection.create(title: "#{current_store.name} - #{current_store.nanoid}")
    end
  end

  def create_billplz_bill(order, collection, uuid)
    Billplz::Bill.create(
      collection.id,
      order.customer&.email || order.customer_email,
      order.customer&.phone_number || order.customer_phone_number,
      order.customer&.name || order.customer_name,
      order.total_cents,
      api_v1_billplz_callback_url(uuid),
      "Order ##{order.nanoid}",
      redirect_url: api_v1_billplz_return_url(uuid),
      reference_1_label: 'order_id',
      reference_1: order.nanoid
    )
  end
end
