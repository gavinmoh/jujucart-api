class Api::V1::User::StoresController < Api::V1::User::ApplicationController
  before_action :set_store, only: [:show, :update, :destroy]
  before_action :set_stores, only: [:index]
  
  def index
    @pagy, @stores = pagy(@stores)
    render json: @stores, adapter: :json
  end

  def show
    render json: @store, adapter: :json
  end

  def create
    @store = pundit_scope(Store).new(store_params)
    pundit_authorize(@store)

    if @store.save
      render json: @store, adapter: :json
    else
      render json: ErrorResponse.new(@store), status: :unprocessable_entity
    end
  end

  def update
    if @store.update(store_params)
      render json: @store, adapter: :json
    else
      render json: ErrorResponse.new(@store), status: :unprocessable_entity
    end
  end

  def destroy
    if @store.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@store), status: :unprocessable_entity
    end
  end

  private
    def set_store
      @store = pundit_scope(Store).find(params[:id])
      pundit_authorize(@store) if @store
    end

    def set_stores
      pundit_authorize(Store)      
      @stores = pundit_scope(Store.all)
      @stores = attribute_sortable(@stores)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::StorePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::StorePolicy)
    end

    def store_params
      params.require(:store).permit(:name, :description, :logo, :remove_logo)
    end
end
