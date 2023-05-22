class Api::V1::User::SalesStatementsController < Api::V1::User::ApplicationController
  before_action :set_sales_statement, only: [:pdf]
  before_action :set_sales_statements, only: [:index]
  
  def index
    @pagy, @sales_statements = pagy(@sales_statements)
    render json: @sales_statements, adapter: :json
  end

  def pdf
    send_data @sales_statement.file.read, type: 'application/pdf', disposition: 'inline', filename: "#{@sales_statement.statement_number}.pdf"
  end

  private
    def set_sales_statement
      @sales_statement = pundit_scope(SalesStatement).find(params[:id])
      pundit_authorize(@sales_statement) if @sales_statement
    end

    def set_sales_statements
      pundit_authorize(SalesStatement)      
      @sales_statements = pundit_scope(SalesStatement.all)
      @sales_statements = keyword_queryable(@sales_statements)
      @sales_statements = attribute_sortable(@sales_statements)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::SalesStatementPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::SalesStatementPolicy)
    end
end
