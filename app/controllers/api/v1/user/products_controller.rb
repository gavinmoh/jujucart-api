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
    @product_variants = @product.product_variants.with_store_quantity(params[:store_id]) if params[:store_id].present?
    render json: @product, adapter: :json, product_variants: @product_variants, include_store_quantity: params[:store_id].present?
  end

  def create
    @product = Product.new(product_params)
    @product.workspace = current_workspace
    pundit_authorize(@product)

    if @product.save
      render json: @product, adapter: :json
    else
      render json: ErrorResponse.new(@product), status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product, adapter: :json, product_variants: @product_variants
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

  def import
    pundit_authorize(Product)
    raise ActionController::ParameterMissing unless import_params[:file].is_a?(String)
    decoded = Base64.decode64(import_params[:file].split(',').second).force_encoding('utf-8').sub("\xEF\xBB\xBF", '')
    file = StringIO.new(decoded)

    products_attributes = SmarterCSV.process(file).map { |x| x.slice(*importable_attributes) }
    category_names = products_attributes.map { |x| x[:category] }.uniq
    categories = Category.where(name: category_names).as_json.map { |x| ActiveSupport::HashWithIndifferentAccess.new(x) }

    ActiveRecord::Base.transaction do
      products_attributes = products_attributes.map do |x|
        if categories.any?
          category_id = categories.find { |category| category[:name] == x[:category] }.dig(:id)
        else
          category_id = nil
        end
        if category_id.present?
          x[:category_id] = category_id
        else
          category = Category.find_or_create_by(name: x[:category])
          x[:category_id] = category.id
        end
        x[:tags] = x[:tags].split if x[:tags].present?
        x[:workspace_id] = current_workspace.id
        x.except(:category)
      end
      @products_array = Product.create!(products_attributes)
    end

    @products = pundit_scope(Product).where(id: @products_array.map(&:id))
    render json: @products, adapter: :json
  rescue => exception
    render json: { error: exception }, status: :unprocessable_entity
  end

  def import_template
    template = CSV.generate do |csv|
      csv << importable_attributes
      csv << ['Potato Chips', 'Onion Flavour', 'Snack', 'snacks foods party', '5.00', '4.50', true, true, true, false, '123456789', 'https://loremflickr.com/g/320/240/lays']
      csv << ['Maggie Noodles', 'Chicken Flavour', 'Noodles', 'noodles foods', '3.00', '0.00', true, true, true, false, '123456790', 'https://loremflickr.com/g/320/240/instantnoodles']
    end
    send_data template, filename: "import_product_templates.csv"
  end

  private
    def set_product
      if params[:store_id].present?
        product_scope = Product.with_store_quantity(params[:store_id])
      else
        product_scope = Product.all
      end
      @product = pundit_scope(product_scope).find(params[:id])
      pundit_authorize(@product) if @product
    end

    def set_products
      pundit_authorize(Product)      
      @products = pundit_scope(Product.includes(:category, :product_variants))
      @products = keyword_queryable(@products)
      @products = @products.where(sku: params[:sku]) if params[:sku].present?
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
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

    def import_params
      params.require(:product).permit(:file)
    end

    def importable_attributes
      %i[name description category tags price discount_price is_featured has_no_variant is_cartable is_hidden sku remote_featured_photo_url]
    end
end
