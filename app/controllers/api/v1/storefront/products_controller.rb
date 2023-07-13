class Api::V1::Storefront::ProductsController < Api::V1::Storefront::ApplicationController
  before_action :set_product, only: [:show]
  before_action :set_products, only: [:index, :all]

  def index
    @pagy, @products = pagy(@products)
    render json: @products, adapter: :json, include: ['category']
  end

  def show
    @product_variants = @product.product_variants.with_store_quantity(current_store.id)
    @product_addons = @product.product_addons.with_store_quantity(current_store.id)
    render json: @product, adapter: :json, product_variants: @product_variants
  end

  def all
    render json: { product_slugs: @products.pluck(:slug) }, status: :ok
  end

  private

    def set_product
      @product = pundit_scope(Product).find_by!(slug: params[:id])
      pundit_authorize(@product) if @product
    end

    def set_products
      pundit_authorize(Product)
      @products = pundit_scope(Product.includes(:category, :product_variants, :product_addons))
      @products = keyword_queryable(@products)
      @products = @products.joins(:category).where(category: { slug: params[:category] }) if params[:category].present?
      @products = @products.where(":tag = ANY (tags)", tag: params[:tag].to_s) if params[:tag].present?
      @products = attribute_sortable(@products)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Storefront::ProductPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Storefront::ProductPolicy)
    end
end
