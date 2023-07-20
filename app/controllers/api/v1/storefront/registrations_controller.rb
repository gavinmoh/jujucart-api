class Api::V1::Storefront::RegistrationsController < Devise::RegistrationsController
  include Storefrontable
  include RackSessionFix
  after_action :create_session, only: [:create]
  respond_to :json

  private

    def sign_up_params
      params.require(:customer).permit(:email, :password, :name, :phone_number).merge(workspace_id: current_workspace.id)
    end

    def respond_with(resource, _opts = {})
      if resource.errors.any?
        render json: ErrorResponse.new(resource), status: :unprocessable_entity
      else
        render json: resource, adapter: :json
      end
    end

    def create_session
      return unless customer_signed_in?

      session = current_customer.sessions.create(
        scope: 'customer',
        # expired_at: Time.now + 1.day,
        user_agent: request.user_agent,
        remote_ip: request.remote_ip,
        referer: request.referer
      )
      response.set_header('Authorization', "Bearer #{session.token}")
    end
end
