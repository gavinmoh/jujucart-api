class Api::V1::User::UsersController < Api::V1::User::ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :set_users, only: [:index]
  
  def index
    @pagy, @users = pagy(@users)
    render json: @users, adapter: :json
  end

  def show
    render json: @user, adapter: :json
  end

  def create
    @user = pundit_scope(User).new(user_params)
    pundit_authorize(@user)

    if @user.save
      render json: @user, adapter: :json
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, adapter: :json
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = pundit_scope(User).find(params[:id])
      pundit_authorize(@user) if @user
    end

    def set_users
      pundit_authorize(User)      
      @users = pundit_scope(User.includes(:assigned_stores, :stores, :latest_session))
      @users = @users.where(role: params[:role]) if params[:role].present?
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::UserPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::UserPolicy)
    end

    def user_params
      params.require(:user).permit(
        :email, :password, :name, :phone_number, :active, :profile_photo, :remove_profile_photo, :role,
        assigned_stores_attributes: [:id, :_destroy, :store_id]
      )
    end
end
