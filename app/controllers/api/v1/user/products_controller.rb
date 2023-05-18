class Api::V1::User::ProductsController < Api::V1::User::ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :set_products, only: [:index]
  
  def index
    if params[:store_id].present?
      @products = @products.with_store_quantity(params[:store_id])
    end

    @pagy, @products = pagy(@products)
    render json: @products, adapter: :json, include: ['category'], include_store_quantity: params[:store_id].present?
  end

  def show
    render json: @product, adapter: :json, store_id: params[:store_id]
  end

  def create
    @product = pundit_scope(Product).new(product_params)
    pundit_authorize(@product)

    if @product.save
      render json: @product, adapter: :json, store_id: params[:store_id]
    else
      render json: ErrorResponse.new(@product), status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product, adapter: :json, store_id: params[:store_id]
    else
      render json: ErrorResponse.new(@product), status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@product), status: :unprocessable_entity
    end
  end

  private
    def set_product
      @product = pundit_scope(Product).find(params[:id])
      pundit_authorize(@product) if @product
    end

    def set_products
      pundit_authorize(Product)      
      @products = pundit_scope(Product.includes(:category, :product_variants))
      @products = keyword_queryable(@products)
      @products = @products.where(category_id: params[:category_id]) if params[:category_id]
      @products = attribute_sortable(@products)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::ProductPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::ProductPolicy)
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :active, :featured_photo, :category_id, :price, :discount_price, 
        :is_featured, :has_no_variant, :is_cartable, :is_hidden, :sku, :remove_featured_photo,
        tags: [], 
        product_attributes: [:name, values: []],
        product_variants_attributes: [
          :id, :name, :description, :featured_photo, :remove_featured_photo, :sku,
          :price, :discount_price, :_destroy,
          product_attributes: [:name, :value]
        ] 
      )
    end
end
