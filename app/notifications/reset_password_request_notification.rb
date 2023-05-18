class ResetPasswordRequestNotification < Noticed::Base
  deliver_by :macrokiosk, class: "DeliveryMethods::Macrokiosk", if: :sms_recipient?

  def sms_recipient?
    recipient.phone_number.present?
  end

  def sms_message
    "A password reset link has been sent to your email address. Please ignore this if you did not request to change your password."
  end

  def sms_to
    recipient.phone_number
  end
  
end
