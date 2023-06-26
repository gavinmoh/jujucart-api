class DeliveryMethods::Macrokiosk < Noticed::DeliveryMethods::Base
  API_ENDPOINT = 'https://www.etracker.cc/bulksms/send'.freeze

  def deliver
    response = Excon.post(
      API_ENDPOINT,
      headers: {
        Accept: "application/json",
        'Content-Type': "application/json"
      },
      body: {
        user: ENV.fetch('MACROKIOSK_USERNAME', nil),
        pass: ENV.fetch('MACROKIOSK_PASSWORD', nil),
        type: "0",
        from: 'Jujucart',
        to: formatted_phone_number,
        text: notification.sms_message,
        servid: ENV.fetch('MACROKIOSK_SERVICE_ID', nil)
      }.to_json,
      idempotent: true,
      expects: [200],
      retry_limit: 5
    )
    response_data = ActiveSupport::JSON.decode(response.body)
    raise MacrokioskDeliverError if response_data['Status'] != '200'
  end

  def formatted_phone_number
    if notification.sms_to.starts_with?('60')
      notification.sms_to
    elsif notification.sms_to.starts_with?('0')
      "6#{notification.sms_to}"
    else
      "60#{notification.sms_to}"
    end
  end

  class MacrokioskDeliverError < StandardError; end
end
