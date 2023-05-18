class Api::V1::User::PasswordsController < Devise::PasswordsController
  respond_to :json

  private
    def respond_with(resource, _opts = {})
      if resource.present? and resource.errors.present?
        render json: ErrorResponse.new(resource), status: :unprocessable_entity
      else
        send_password_notification
        render json: resource, adapter: :json
      end
    end

    def send_password_notification
      case action_name
      when "create"
        ResetPasswordRequestNotification.deliver_later(resource)
      when "update"
        ResetPasswordSuccessNotification.deliver_later(resource)
      end
    end

    def after_resetting_password_path_for(_resource)
      nil
    end
end
