class DeliveryMethods::Firebase < Noticed::DeliveryMethods::Base
  def deliver
    badge_count = recipient.badge_count
    client = FCM::Client.new(
      title: notification.subject,
      body: notification.message,
      priority: notification.try(:fcm_priority),
      data: notification.try(:fcm_data_payload),
      badge_count: badge_count,
      webpush_url: notification.try(:webpush_url)
    )
    recipient.notification_tokens.find_each do |nt|
      response = client.push(nt.token)
      nt.destroy if ['404', '500'].include?(response.status.to_s)      
    end
  end

  # You may override this method to validate options for the delivery method
  # Invalid options should raise a ValidationError
  #
  # def self.validate!(options)
  #   raise ValidationError, "required_option missing" unless options[:required_option]
  # end
end
