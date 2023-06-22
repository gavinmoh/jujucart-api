class Api::V1::User::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix
  after_action :create_session, only: [:create]
  respond_to :json

  private
    def sign_up_params
      params.require(:user).permit(:email, :name, :phone_number, :password, :password_confirmation, :profile_photo)
    end

    def respond_with(resource, _opts = {})
      if resource.errors.any?
        render json: ErrorResponse.new(resource), status: :unprocessable_entity
      else
        workspace = Workspace.create!(name: "#{resource.name}'s Workspace", created_by: resource)
        resource.user_workspaces.create!(workspace: workspace)
        render json: resource, adapter: :json
      end
    end

    def create_session
      return unless user_signed_in?
      session = current_user.sessions.create(
        scope: 'user',
        # expired_at: Time.now + 1.day,
        user_agent: request.user_agent,
        remote_ip: request.remote_ip,
        referer: request.referer
      )
      response.set_header('Authorization', "Bearer #{session.token}")
    end
end



