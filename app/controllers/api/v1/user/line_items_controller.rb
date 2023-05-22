class Api::V1::User::LineItemsController < Api::V1::User::ApplicationController
  before_action :set_order
  before_action :set_line_item, only: [:show, :update, :destroy]
  before_action :set_line_items, only: [:index]
  
  def index
    render json: @line_items.includes(:product), adapter: :json
  end

  def show
    render json: @line_item, adapter: :json
  end

  def create
    @line_item = @order.line_items.find_or_initialize_by(product_id: line_item_params[:product_id])
    pundit_authorize(@line_item) if @line_item

    if @line_item.quantity != 0
      @line_item.quantity = @line_item.quantity + line_item_params[:quantity].to_i
    else
      @line_item.quantity = line_item_params[:quantity]
    end
    
    if @line_item.save
      render json: @line_item, adapter: :json
    else
      render json: ErrorResponse.new(@line_item), status: :unprocessable_entity
    end
  end

  def update
    if @line_item.update(line_item_params)
      render json: @line_item, adapter: :json
    else
      render json: ErrorResponse.new(@line_item), status: :unprocessable_entity
    end
  end

  def destroy
    if @line_item.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@line_item), status: :unprocessable_entity
    end
  end

  private
    def set_order
      @order = policy_scope(Order.includes({line_items: :product}), policy_scope_class: Api::V1::User::OrderPolicy::Scope).find(params[:order_id])      
    end

    def set_line_item
      @line_item = @order.line_items.find(params[:id])
      pundit_authorize(@line_item) if @line_item
    end

    def set_line_items
      @line_items = @order.line_items.includes(:product, :promotion_bundle)
      @line_items = attribute_sortable(@line_items)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::LineItemPolicy)
    end

    def line_item_params
      params.require(:line_item).permit(:product_id, :quantity)
    end
end
