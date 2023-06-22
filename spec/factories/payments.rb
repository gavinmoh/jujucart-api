FactoryBot.define do
  factory :payment do
    transient { workspace { create(:workspace) } }
    order_id { create(:order, workspace: workspace).id }
    payment_type { 'cash' }
    transaction_reference { SecureRandom.hex(10) }
    amount { Faker::Number.within(range: 10..1000).to_s }

    after(:build) do |payment, evaluator|
      payment.workspace = evaluator.workspace if payment.workspace.nil?
    end

    trait :revenue_monster do
      payment_type { 'terminal' }
      payment_method { 'CARD' }
      terminal_id { create(:pos_terminal).terminal_id }
      revenue_monster {
        {
          "balanceAmount": 10,
          "createdAt": "2021-02-17T18:39:30Z",
          "currencyType": "MYR",
          "extraInfo": {
            "card": {
              "inputType": "NFC",
              "maskNo": "XXXX-XXXX-XXXX-9081",
              "referenceId": "104983001779",
              "secondaryReferenceId": "001779"
            }
          },
          "method": "CARD",
          "order": {
            "additionalData": "010100 Pay parking ticket\n30/07/20 07:13 - 30/07/20 18:40\nLength of stay: 0 Days. 11:35\n02993777014011020212260030??",
            "amount": 10,
            "detail": "desc",
            "id": "387153091916665362292147",
            "title": "title"
          },
          "payee": {
            "userId": "1000000806040489"
          },
          "platform": "TERMINAL",
          "referenceId": "00000000000550520003236104983001779",
          "region": "MALAYSIA",
          "status": "SUCCESS",
          "store": {
            "addressLine1": "UTROPOLIS MARKETPLACE,  JALAN KONTRAKTOR U1/14,  SHAH ALAM",
            "addressLine2": "UTROPOLIS MARKETPLACE,  JALAN KONTRAKTOR U1/14,  SHAH ALAM",
            "city": "Shah Alam",
            "country": "Malaysia",
            "countryCode": "60",
            "createdAt": "2021-01-08T10:09:23Z",
            "geoLocation": {
              "latitude": 3.0901139,
              "longitude": 101.55987
            },
            "id": "1601912947341252990",
            "name": "Mountain Food - Utropolis",
            "phoneNumber": "1123621544",
            "postCode": "40150",
            "state": "Selangor",
            "status": "ACTIVE",
            "updatedAt": "2021-01-08T10:09:23Z"
          },
          "transactionAt": "2021-02-18T02:39:35+08:00",
          "transactionId": "210217183930100325434403",
          "type": "BANK_CARD",
          "updatedAt": "2021-02-17T18:39:37Z"
        }
      }
    end
  end
end