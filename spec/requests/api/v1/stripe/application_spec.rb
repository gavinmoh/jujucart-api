require 'swagger_helper'

RSpec.describe 'api/v1/stripe/', type: :request do
  let(:workspace) { create(:workspace, stripe_account_id: '123', stripe_charges_enabled: true, default_payment_gateway: 'Stripe') }
  let(:store) { create(:store, workspace: workspace, store_type: 'online', hostname: 'www.example.com') }
  let(:order) { create(:order, :with_line_items, workspace: workspace, store_id: store.id, customer_id: nil) }
  let(:payment) { order.pending_stripe_payment }
  let(:payment_id) { payment.id }

  before do
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  path '/api/v1/stripe/return/{payment_id}' do
    parameter name: :payment_id, in: :path, type: :string

    get('return') do
      tags 'Stripe'

      parameter name: :status, in: :query, type: :string

      response(302, 'successful') do
        context 'when it is success' do
          let(:status) { 'success' }

          before do
            put checkout_api_v1_storefront_order_path(order.id)
            session = StripeMock.instance.checkout_sessions[payment.transaction_reference]
            session[:payment_status] = 'paid'
            session[:status] = 'completed'
          end

          run_test! do |response|
            expect(response.headers["Location"]).to include("payment_success")
            order.reload
            expect(order.status).to eq('confirmed')
            payment.reload
            expect(payment.status).to eq('success')
          end
        end

        context 'when it is cancel' do
          let(:status) { 'cancel' }

          before do
            put checkout_api_v1_storefront_order_path(order.id)
            session = StripeMock.instance.checkout_sessions[payment.transaction_reference]
            session[:payment_status] = 'unpaid'
            session[:status] = 'open'
          end

          run_test! do |response|
            expect(response.headers["Location"]).to include("payment_cancel")
            order.reload
            expect(order.status).to eq('pending_payment')
            payment.reload
            expect(payment.status).to eq('cancelled')
          end
        end

        context 'when it is expired' do
          before do
            put checkout_api_v1_storefront_order_path(order.id)
            session = StripeMock.instance.checkout_sessions[payment.transaction_reference]
            session[:payment_status] = 'unpaid'
            session[:status] = 'expired'
          end

          run_test! do |response|
            expect(response.headers["Location"]).to include("payment_fail")
            order.reload
            expect(order.status).to eq('pending_payment')
            payment.reload
            expect(payment.status).to eq('failed')
          end
        end

        context 'when it is completed but unpaid' do
          before do
            put checkout_api_v1_storefront_order_path(order.id)
            session = StripeMock.instance.checkout_sessions[payment.transaction_reference]
            session[:payment_status] = 'unpaid'
            session[:status] = 'completed'
          end

          run_test! do |response|
            expect(response.headers["Location"]).to include("payment_fail")
            order.reload
            expect(order.status).to eq('pending_payment')
            payment.reload
            expect(payment.status).to eq('failed')
          end
        end
      end
    end
  end
end
