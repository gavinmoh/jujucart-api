class Api::V1::User::CategoriesController < Api::V1::User::ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]
  before_action :set_categories, only: [:index]
  
  def index
    @pagy, @categories = pagy(@categories)
    render json: @categories, adapter: :json
  end

  def show
    render json: @category, adapter: :json
  end

  def create
    @category = pundit_scope(Category).new(category_params)
    pundit_authorize(@category)

    if @category.save
      render json: @category, adapter: :json
    else
      render json: ErrorResponse.new(@category), status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, adapter: :json
    else
      render json: ErrorResponse.new(@category), status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@category), status: :unprocessable_entity
    end
  end

  private
    def set_category
      @category = pundit_scope(Category).find(params[:id])
      pundit_authorize(@category) if @category
    end

    def set_categories
      pundit_authorize(Category)      
      @categories = pundit_scope(Category.all)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::CategoryPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::CategoryPolicy)
    end

    def category_params
      params.require(:category).permit(:name, :display_order, :photo, :remove_photo)
    end
end
