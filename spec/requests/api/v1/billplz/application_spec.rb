require 'swagger_helper'

RSpec.describe 'api/v1/billplz/', type: :request do
  let(:workspace) { create(:workspace, default_payment_gateway: 'Billplz') }
  let(:store) { create(:store, workspace: workspace, store_type: 'online', hostname: 'www.example.com') }
  let(:order) { create(:order, :with_line_items, workspace: workspace, store_id: store.id, customer_id: nil) }
  let(:payment) { order.pending_billplz_payment }
  let(:payment_id) { payment.id }
  let(:billplz_payload) do
    {
      billplzid: payment.transaction_reference,
      billplzpaid: 'true',
      billplzpaid_at: Time.current.strftime('%Y-%m-%d %H:%M:%S'),
      billplztransaction_id: SecureRandom.uuid,
      billplztransaction_status: 'completed'
    }
  end

  path '/api/v1/billplz/return/{payment_id}' do
    parameter name: :payment_id, in: :path, type: :string

    get('return') do
      tags 'Billplz'
      produces 'application/json'
      consumes 'application/json'

      parameter name: 'billplz[id]', in: :query, type: :string
      parameter name: 'billplz[paid]', in: :query, type: :string
      parameter name: 'billplz[paid_at]', in: :query, type: :string
      parameter name: 'billplz[transaction_id]', in: :query, type: :string
      parameter name: 'billplz[transaction_status]', in: :query, type: :string
      parameter name: 'billplz[x_signature]', in: :query, type: :string

      response(302, 'successful') do
        let(:'billplz[id]') { billplz_payload[:billplzid] }
        let(:'billplz[paid]') { billplz_payload[:billplzpaid] }
        let(:'billplz[paid_at]') { billplz_payload[:billplzpaid_at] }
        let(:'billplz[transaction_id]') { billplz_payload[:billplztransaction_id] }
        let(:'billplz[transaction_status]') { billplz_payload[:billplztransaction_status] }
        let(:'billplz[x_signature]') { Billplz::Signature.generate(billplz_payload) }

        before do
          put checkout_api_v1_storefront_order_path(order.id)
        end

        run_test! do
          order.reload
          expect(order.status).to eq('confirmed')
        end
      end
    end
  end

  path '/api/v1/billplz/callback/{payment_id}' do
    parameter name: :payment_id, in: :path, type: :string

    post('callback') do
      tags 'Billplz'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string },
          collection_id: { type: :string },
          paid: { type: :boolean },
          state: { type: :string },
          amount: { type: :string },
          paid_amount: { type: :string },
          due_at: { type: :string },
          email: { type: :string },
          mobile: { type: :string },
          name: { type: :string },
          url: { type: :string },
          paid_at: { type: :string },
          transaction_id: { type: :string },
          transaction_status: { type: :string },
          x_signature: { type: :string }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:billplz_payload) do
          {
            id: payment.transaction_reference,
            collection_id: payment.billplz['collection_id'],
            paid: true,
            state: 'paid',
            amount: payment.billplz['amount'],
            paid_amount: payment.billplz['amount'],
            due_at: payment.billplz['due_at'],
            email: payment.billplz['email'],
            mobile: payment.billplz['mobile'],
            name: payment.billplz['name'],
            url: payment.billplz['url'],
            paid_at: Time.current.strftime('%Y-%m-%d %H:%M:%S'),
            transaction_id: SecureRandom.uuid,
            transaction_status: 'completed'
          }
        end
        let(:data) { billplz_payload.merge(x_signature: Billplz::Signature.generate(billplz_payload)) }

        before do
          put checkout_api_v1_storefront_order_path(order.id)
        end

        run_test! do
          order.reload
          expect(order.status).to eq('confirmed')
        end
      end
    end
  end
end
