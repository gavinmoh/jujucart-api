class Api::V1::User::PosTerminalsController < Api::V1::User::ApplicationController
  before_action :set_pos_terminal, only: [:show, :update, :destroy]
  before_action :set_pos_terminals, only: [:index]
  
  def index
    @pagy, @pos_terminals = pagy(@pos_terminals)
    render json: @pos_terminals, adapter: :json
  end

  def show
    render json: @pos_terminal, adapter: :json
  end

  def create
    @pos_terminal = pundit_scope(PosTerminal).new(pos_terminal_params)
    pundit_authorize(@pos_terminal)
    
    if @pos_terminal.save
      render json: @pos_terminal, adapter: :json
    else
      render_error_json(@pos_terminal)
    end
  end

  def update
    if @pos_terminal.update(pos_terminal_params)
      render json: @pos_terminal, adapter: :json
    else
      render_error_json(@pos_terminal)
    end
  end

  def destroy
    if @pos_terminal.destroy
      head :no_content
    else
      render_error_json(@pos_terminal)
    end
  end

  private
    def set_pos_terminal
      @pos_terminal = pundit_scope(PosTerminal).find(params[:id])
      pundit_authorize(@pos_terminal) if @pos_terminal
    end

    def set_pos_terminals
      pundit_authorize(PosTerminal)      
      @pos_terminals = pundit_scope(PosTerminal.includes(:store))
      @pos_terminals = @pos_terminals.where(store_id: params[:store_id]) if params[:store_id].present?
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::PosTerminalPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::PosTerminalPolicy)
    end

    def pos_terminal_params
      params.require(:pos_terminal).permit(:store_id, :terminal_id, :label)
    end
end
