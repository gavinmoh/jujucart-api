class Api::V1::Storefront::SessionsController < Devise::SessionsController
  include RackSessionFix
  include Storefrontable
  respond_to :json

  def create
    self.resource = Customer.find_by(email: sign_in_params[:email], workspace_id: current_workspace.id)

    if resource&.valid_password?(sign_in_params[:password])
      sign_in(resource_name, resource)
      yield resource if block_given?
      render json: resource, adapter: :json
    else
      render json: ErrorResponse.new('Invalid email or password.'), status: :unauthorized
    end
  end

  private

    # def sign_in_params
    #   params.require(:storefront).permit(:email, :password)
    # end

    # directly override devise respond method since we're only using JSON
    def respond_with(resource, _opts = {})
      render json: resource, adapter: :json
    end

    def respond_to_on_destroy
      head :no_content
    end
end
