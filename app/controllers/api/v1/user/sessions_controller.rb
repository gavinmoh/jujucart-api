class Api::V1::User::SessionsController < Devise::SessionsController
  respond_to :json

  private
    # def sign_in_params
    #   params.require(:user).permit(:email, :password)
    # end

    # directly override devise respond method since we're only using JSON
    def respond_with(resource, _opts = {})
      render json: resource, adapter: :json
    end

    def respond_to_on_destroy
      head :no_content
    end
end
