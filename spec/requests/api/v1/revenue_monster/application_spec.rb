require 'swagger_helper'

RSpec.describe 'api/v1/revenue_monster/', type: :request do

  path '/api/v1/revenue_monster/callback' do

    post('callback') do
      tags 'Revenue Monster'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: { type: :object }
      
      response(200, 'successful') do
        let(:order) { create(:order, status: 'completed', order_type: 'pos') }
        let(:payment) { create(:payment, :revenue_monster, status: 'success', order_id: order.id) }
        let(:transaction_id) { payment.transaction_reference }
        let(:data) { {
          "code"=>"SUCCESS",
          "item"=>
           {"balanceAmount"=>0,
            "createdAt"=>"2023-05-03T07:40:52Z",
            "currencyType"=>"MYR",
            "extraInfo"=>
             {"card"=>{"inputType"=>"NFC", "maskNo"=>"XXXX-XXXX-XXXX-0320", "referenceId"=>"312315000037", "secondaryReferenceId"=>"000037"}},
            "method"=>"CARD",
            "order"=>
             {"additionalData"=>"a2de825b-486f-4b36-a89b-be34bceda5ea", "amount"=>100, "detail"=>"", "id"=>"8db3adwei4", "title"=>"JCMPWUAT"},
            "platform"=>"TERMINAL",
            "referenceId"=>"00000460000022366624692312315000037",
            "region"=>"MALAYSIA",
            "status"=>"FULL_REFUNDED",
            "store"=>
             {"addressLine1"=>"NO 9, JALAN PJS 11/24,",
              "addressLine2"=>"BANDAR SUNWAY,",
              "city"=>"Petaling Jaya",
              "country"=>"Malaysia",
              "countryCode"=>"60",
              "createdAt"=>"2023-03-21T06:46:09Z",
              "geoLocation"=>{"latitude"=>0.0, "longitude"=>0.0},
              "id"=>"1679381169473021418",
              "name"=>"Evabuy",
              "phoneNumber"=>"1156389663",
              "postCode"=>"47500",
              "state"=>"Selangor",
              "status"=>"ACTIVE",
              "updatedAt"=>"2023-04-12T08:29:28Z"},
            "transactionAt"=>"2023-05-03T07:41:04Z",
            "transactionId"=>transaction_id,
            "type"=>"BANK_CARD",
            "updatedAt"=>"2023-05-03T07:45:35Z"}
        }}
        
        run_test! do
          expect(payment.reload.status).to eq('refunded')
          expect(order.reload.status).to eq('refunded')
          expect(CallbackLog.exists?(callback_from: 'RevenueMonster', request_body: data.to_json)).to be_truthy
        end
      end   
    end
  end
end
