class Api::V1::User::CustomersController < Api::V1::User::ApplicationController
  before_action :set_customer, only: [:show, :update, :destroy]
  before_action :set_customers, only: [:index]
  
  def index
    @pagy, @customers = pagy(@customers)
    render json: @customers, adapter: :json
  end

  def show
    render json: @customer, adapter: :json
  end

  def create
    @customer = pundit_scope(Customer).new(customer_params)
    pundit_authorize(@customer)

    if @customer.save
      render json: @customer, adapter: :json
    else
      render json: ErrorResponse.new(@customer), status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: @customer, adapter: :json
    else
      render json: ErrorResponse.new(@customer), status: :unprocessable_entity
    end
  end

  # def destroy
  #   if @customer.destroy
  #     head :no_content
  #   else
  #     render json: ErrorResponse.new(@customer), status: :unprocessable_entity
  #   end
  # end

  private
    def set_customer
      @customer = pundit_scope(Customer.all).find(params[:id])
      pundit_authorize(@customer) if @customer
    end

    def set_customers
      pundit_authorize(Customer)
      @customers = pundit_scope(Customer.includes(:wallet))
      @customers = keyword_queryable(@customers)
      @customers = @customers.where(active: ActiveModel::Type::Boolean.new.cast(params[:active])) if params[:active].present? 
      @customers = attribute_date_scopable(@customers)
      @customers = attribute_sortable(@customers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::CustomerPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::CustomerPolicy)
    end

    def customer_params
      params.require(:customer).permit(:email, :name, :phone_number, :active, :password, :profile_photo, :remove_profile_photo)
    end
end
