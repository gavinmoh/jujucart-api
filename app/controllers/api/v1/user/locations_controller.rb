class Api::V1::User::LocationsController < Api::V1::User::ApplicationController
  before_action :set_location, only: [:show, :update, :destroy]
  before_action :set_locations, only: [:index]
  
  def index
    @pagy, @locations = pagy(@locations)
    render json: @locations, adapter: :json
  end

  def show
    render json: @location, adapter: :json
  end

  def create
    @location = pundit_scope(Location).new(location_params)
    pundit_authorize(@location)

    if @location.save
      render json: @location, adapter: :json
    else
      render json: ErrorResponse.new(@location), status: :unprocessable_entity
    end
  end

  def update
    if @location.update(location_params)
      render json: @location, adapter: :json
    else
      render json: ErrorResponse.new(@location), status: :unprocessable_entity
    end
  end

  def destroy
    if @location.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@location), status: :unprocessable_entity
    end
  end

  private
    def set_location
      @location = pundit_scope(Location).find(params[:id])
      pundit_authorize(@location) if @location
    end

    def set_locations
      pundit_authorize(Location)      
      @locations = pundit_scope(Location.includes(:store))
      @locations = @locations.non_store if params[:exclude_store].present? && ActiveModel::Type::Boolean.new.cast(params[:exclude_store])
      @locations = keyword_queryable(@locations)
      @locations = attribute_sortable(@locations)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::LocationPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::LocationPolicy)
    end

    def location_params
      params.require(:location).permit(:name)
    end
end
