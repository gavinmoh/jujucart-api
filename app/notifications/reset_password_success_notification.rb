class ResetPasswordSuccessNotification < Noticed::Base
  deliver_by :macrokiosk, class: "DeliveryMethods::Macrokiosk", if: :sms_recipient?

  def sms_recipient?
    recipient.phone_number.present?
  end

  def sms_message
    "Your password had been reset successfully! Kindly log in to your Blank App."
  end

  def sms_to
    recipient.phone_number
  end
  
end
