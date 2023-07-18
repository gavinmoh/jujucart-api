class BillplzReconcilationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(payment_id)
    payment = Payment.find(payment_id)
    return unless payment.service_provider == 'billplz'
    return unless payment.pending?

    bill = Billplz::Bill.get(payment.transaction_reference)
    payment.update(
      billplz: bill,
      reconciled_at: Time.current
    )
  end
end
