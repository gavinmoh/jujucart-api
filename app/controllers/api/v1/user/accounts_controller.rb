class Api::V1::User::AccountsController < Api::V1::User::ApplicationController
  before_action :set_account, only: [:show, :update, :password]
  
  def show
    render json: @account, adapter: :json
  end

  def update
    if @account.update(account_params)
      render json: @account, adapter: :json
    else
      render json: ErrorResponse.new(@account), status: :unprocessable_entity
    end
  end

  def password
    current_password = password_params[:current_password]
    password_attributes = password_params.except(:current_password)

    if @account.valid_password?(current_password) and
       @account.update(password_attributes)
      render json: @account, adapter: :json
    else
      render json: ErrorResponse.new(@account), status: :unprocessable_entity
    end
  end

  private
    def set_account
      @account = current_user
    end

    def account_params
      params.require(:account).permit(:name, :phone_number, :email, :profile_photo, :remove_profile_photo)
    end

    def password_params
      params.require(:account).permit(:current_password, :password, :password_confirmation)
    end
end
