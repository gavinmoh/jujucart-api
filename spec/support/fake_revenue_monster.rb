require 'sinatra/base'

class FakeRevenueMonster < Sinatra::Base

  post '/v1/token' do
    status 200
    {
      "accessToken": SecureRandom.alphanumeric(128),
      "tokenType": "Bearer",
      "expiresIn": 2591999,
      "refreshToken": SecureRandom.alphanumeric(128),
      "refreshTokenExpiresIn": 1576799999
    }.to_json    
  end

  post '/v3/payment/terminal/quickpay' do
    status 200
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
    }.to_json    
  end

  post '/v3/event/terminal' do
    body_text = request.body.read
    parsed_body = JSON.parse(body_text)

    status 200
    case parsed_body['type'] 
    when 'CANCEL'
      {
        "code": "SUCCESS"
      }.to_json
    when 'REFUND'
      {
        "code": "SUCCESS",
        "item": {
          "balanceAmount": 0,
          "createdAt": "2021-02-17T17:43:59Z",
          "currencyType": "MYR",
          "extraInfo": {
            "card": {
              "inputType": "NFC",
              "maskNo": "XXXX-XXXX-XXXX-9081",
              "referenceId": "104974001774",
              "secondaryReferenceId": "001774"
            }
          },
          "method": "CARD",
          "order": {
            "additionalData": "In store payment",
            "amount": 10,
            "detail": "[Terminal app] Pay to Mountain Food - Utropolis",
            "id": "1613583839549PE24191B504",
            "title": "In store payment"
          },
          "platform": "TERMINAL",
          "referenceId": "00000000000550520003236104974001774",
          "region": "MALAYSIA",
          "status": "FULL_REFUNDED",
          "transactionAt": "2021-02-17T17:44:02Z",
          "transactionId": "210217174359100325085446",
          "type": "BANK_CARD",
          "updatedAt": "2021-02-17T17:44:30Z"
        }
      }.to_json
    end
  end





end