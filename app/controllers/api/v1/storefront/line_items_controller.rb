class Api::V1::Storefront::LineItemsController < Api::V1::Storefront::ApplicationController
  before_action :set_order
  before_action :set_line_item, only: [:show, :update, :destroy]
  before_action :set_line_items, only: [:index]
  before_action :find_or_initialize_line_item, only: [:create]

  def index
    render json: @line_items.includes(:product), adapter: :json
  end

  def show
    render json: @line_item, adapter: :json
  end

  def create
    pundit_authorize(@line_item)

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
      @order = Order.includes({ line_items: :product })
                    .where(workspace_id: current_workspace.id)
                    .find(params[:order_id])
      authorize(@order, :show?, policy_class: Api::V1::Storefront::OrderPolicy)
    end

    def set_line_item
      @line_item = @order.line_items.find(params[:id])
      pundit_authorize(@line_item) if @line_item
    end

    def set_line_items
      @line_items = @order.line_items.includes(:product, :promotion_bundle)
      @line_items = attribute_sortable(@line_items)
    end

    def find_or_initialize_line_item
      if line_item_params[:line_item_addons_attributes].present?
        @line_item = @order.line_items.new(line_item_params)
      else
        @line_item = @order.line_items.find_or_initialize_by(product_id: line_item_params[:product_id])
        @line_item.quantity = if @line_item.persisted?
                                @line_item.quantity + (line_item_params[:quantity].to_i || 1)
                              else
                                line_item_params[:quantity] || 1
                              end
      end
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Storefront::LineItemPolicy)
    end

    def line_item_params
      params.require(:line_item).permit(:product_id, :quantity, line_item_addons_attributes: [:id, :product_addon_id, :_destroy])
    end
end
