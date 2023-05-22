class GenerateSalesStatementPdfWorker
  include Sidekiq::Worker

  def perform(sales_statement_id = nil)
    if sales_statement_id.present?
      sales_statement = SalesStatement.find(sales_statement_id)
    else
      sales_statement = SalesStatement.create!(
        from_date: Time.current.last_month.beginning_of_month.to_date,
        to_date: Time.current.last_month.end_of_month.to_date
      )
    end

    statement_html = ActionController::Base.new.render_to_string(
      template: 'api/v1/user/sales_statements/sales_statement',
      layout: false,
      locals: {
        :sales_statement => sales_statement,
        :orders => sales_statement.orders.includes(:line_items)
      }
    )

    statement_pdf = WickedPdf.new.pdf_from_string(statement_html,
      page_size: 'A4',
      margin: {top: 0, bottom: 0, left: 0, right: 0 }
    )

    begin
      tempfile = Tempfile.new([sales_statement.statement_number, '.pdf'])
      tempfile.binmode
      tempfile.write statement_pdf
      tempfile.close
      sales_statement.update!(file: tempfile)
    ensure
      tempfile.unlink if tempfile
    end
  end
end
