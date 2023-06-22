class Api::V1::User::OrderAttachmentsController < Api::V1::User::ApplicationController
  before_action :set_order_attachment, only: [:show, :update, :destroy]
  before_action :set_order_attachments, only: [:index]
  
  def index
    @pagy, @order_attachments = pagy(@order_attachments)
    render json: @order_attachments, adapter: :json
  end

  def show
    render json: @order_attachment, adapter: :json
  end

  def create
    @order_attachment = OrderAttachment.new(order_attachment_params)
    pundit_authorize(@order_attachment)

    if @order_attachment.save
      render json: @order_attachment, adapter: :json
    else
      render json: ErrorResponse.new(@order_attachment), status: :unprocessable_entity
    end
  end

  def update
    if @order_attachment.update(order_attachment_params)
      render json: @order_attachment, adapter: :json
    else
      render json: ErrorResponse.new(@order_attachment), status: :unprocessable_entity
    end
  end

  def destroy
    if @order_attachment.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@order_attachment), status: :unprocessable_entity
    end
  end

  private
    def set_order_attachment
      @order_attachment = pundit_scope(OrderAttachment).find(params[:id])
      pundit_authorize(@order_attachment) if @order_attachment
    end

    def set_order_attachments
      pundit_authorize(OrderAttachment)      
      @order_attachments = pundit_scope(OrderAttachment.includes(:order))
      @order_attachments = @order_attachments.where(order_id: params[:order_id]) if params[:order_id].present?
      @order_attachments = keyword_queryable(@order_attachments)
      @order_attachments = attribute_sortable(@order_attachments)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::OrderAttachmentPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::OrderAttachmentPolicy)
    end

    def order_attachment_params
      params.require(:order_attachment).permit(:order_id, :file, :name)
    end
end
