class Api::V1::User::ReportsController < Api::V1::User::ApplicationController
  def overview
    from_date = params[:from_date].present? ? (Date.parse(params[:from_date]).beginning_of_day rescue Date.today.beginning_of_day) : Date.today.beginning_of_month.beginning_of_day
    to_date = params[:to_date].present? ? (Date.parse(params[:to_date]).end_of_day rescue Date.today.end_of_day) : Date.today.end_of_month.end_of_day

    orders = Order.where(status: 'completed', completed_at: from_date..to_date)
    orders = orders.where(store_id: params[:store_id]) if params[:store_id].present?
    orders = orders.where(created_by_id: params[:created_by_id]) if params[:created_by_id].present?

    customers = Customer.where(created_at: from_date..to_date)
    total_sales = Money.new(orders.sum(:total_cents)).as_json

    total_sales_report = group_sales(orders: orders, from_date: from_date, to_date: to_date)

    total_item_sold =
      orders.
        joins(:line_items).
        select('SUM(line_items.quantity) AS total_sold').
        as_json.first['total_sold']

    total_item_sold_report = group_item_sold(orders: orders, from_date: from_date, to_date: to_date)

    total_transactions = orders.count

    total_transactions_report = group_transactions(orders: orders, from_date: from_date, to_date: to_date)

    total_customers = customers.count
    total_customers_report = group_customers(customers: customers, from_date: from_date, to_date: to_date)

    render json: {
      from_date: from_date.to_s,
      to_date: to_date.to_s,
      total_sales: total_sales,
      total_sales_report: total_sales_report,
      total_item_sold: total_item_sold,
      total_item_sold_report: total_item_sold_report,
      total_transactions: total_transactions,
      total_transactions_report: total_transactions_report,
      total_member_count: total_customers,
      total_member_report: total_customers_report
    }
  end

  def best_seller_products
    from_date = params[:from_date].present? ? (Date.parse(params[:from_date]) rescue Date.current.beginning_of_month) : Date.current.beginning_of_month
    to_date = params[:to_date].present? ? (Date.parse(params[:to_date]) rescue Date.current.end_of_month) : Date.current.end_of_month
    metric = params[:metric].present? ? params[:metric] : 'sold_quantity'

    @products = Product.all.eager_load(:category)
    @products = @products.bestseller(
      from_date: from_date, 
      to_date: to_date,
      metric: metric, 
      store_id: params[:store_id]
    )

    render json: @products, adapter: :json, include: ['category'], each_serializer: Api::V1::User::BestSellerProductSerializer
  end

  def best_seller_categories
    from_date = params[:from_date].present? ? (Date.parse(params[:from_date]) rescue Date.current.beginning_of_month) : Date.current.beginning_of_month
    to_date = params[:to_date].present? ? (Date.parse(params[:to_date]) rescue Date.current.end_of_month) : Date.current.end_of_month
    metric = params[:metric].present? ? params[:metric] : 'sold_quantity'

    @categories = Category.bestseller(
                    from_date: from_date, 
                    to_date: to_date,
                    store_id: params[:store_id],
                    metric: metric
                  )
    @products = Product.all.eager_load(:category)
                           .bestseller(
                              from_date: from_date,
                              to_date: to_date,
                              limit: nil,
                              metric: metric,
                              store_id: params[:store_id])
                           .having("SUM(line_items.quantity) > 0")

    render json: @categories, adapter: :json, products: @products, each_serializer: Api::V1::User::BestSellerCategorySerializer
  end

  private
    def generate_range_steps(from_date:, to_date:)
      if from_date == to_date
        24.times.map do |hour|
          (from_date.beginning_of_day + hour.hour).utc.iso8601
        end
      else
        (from_date..to_date).to_a.map { |date| date.to_time.utc.iso8601 }
      end
    end

    def group_sales(orders:, from_date:, to_date:)
      grouping_statement =
        if from_date.to_date == to_date.to_date
          "DATE_TRUNC('hour', orders.completed_at)"
        else
          "DATE(orders.completed_at)"
        end

      steps = generate_range_steps(from_date: from_date.to_date, to_date: to_date.to_date)
      initial_hash = steps.map do |step|
        {
          "date" => step,
          "sales" => {
            "cents" => 0,
            "currency" => Money.default_currency.iso_code
          }
        }
      end

      orders_hash =
        orders.
          select(Arel.sql("#{grouping_statement} AS date, SUM(orders.total_cents) AS cents")).
          group(Arel.sql(grouping_statement)).
          order(Arel.sql(grouping_statement)).
          as_json.map do |order|
            { "date" => order['date'].to_time.utc.iso8601, "sales" => Money.new(order['cents']).as_json }
          end

      orders_hash.each { |order| initial_hash.delete_if { |hash| hash['date'].to_time == order['date'].to_time } }
      (initial_hash + orders_hash).sort {|a, b| a["date"] <=> b["date"]}
    end

    def group_item_sold(orders:, from_date:, to_date:)
      grouping_statement =
        if from_date.to_date == to_date.to_date
          "DATE_TRUNC('hour', orders.completed_at)"
        else
          "DATE(orders.completed_at)"
        end

      steps = generate_range_steps(from_date: from_date.to_date, to_date: to_date.to_date)
      initial_hash = steps.map do |step|
        {
          "date" => step,
          "count" => 0
        }
      end

      orders_hash =
        orders.
          select(Arel.sql("#{grouping_statement} AS date, SUM(line_items.quantity) AS count")).
          joins(:line_items).
          group(Arel.sql(grouping_statement)).
          order(Arel.sql(grouping_statement)).
          as_json.map { |order| { "date" => order['date'].to_time.utc.iso8601, "count" => order['count'] } }

      orders_hash.each { |order| initial_hash.delete_if { |hash| hash['date'].to_time == order['date'].to_time } }

      (initial_hash + orders_hash).sort {|a, b| a["date"] <=> b["date"]}
    end

    def group_transactions(orders:, from_date:, to_date:)
      grouping_statement =
        if from_date.to_date == to_date.to_date
          "DATE_TRUNC('hour', orders.completed_at)"
        else
          "DATE(orders.completed_at)"
        end

      steps = generate_range_steps(from_date: from_date.to_date, to_date: to_date.to_date)
      initial_hash = steps.map do |step|
        {
          "date" => step,
          "count" => 0
        }
      end

      orders_hash =
        orders.
          select(Arel.sql("#{grouping_statement} AS date, COUNT(orders.id) AS count")).
          group(Arel.sql(grouping_statement)).
          order(Arel.sql(grouping_statement)).
          as_json.map { |order| { "date" => order['date'].to_time.utc.iso8601, "count" => order['count'] } }

      orders_hash.each { |order| initial_hash.delete_if { |hash| hash['date'].to_time == order['date'].to_time } }

      (initial_hash + orders_hash).sort {|a, b| a["date"] <=> b["date"]}
    end

    def group_customers(customers:, from_date:, to_date:)
      grouping_statement =
        if from_date.to_date == to_date.to_date
          "DATE_TRUNC('hour', accounts.created_at)"
        else
          "DATE(accounts.created_at)"
        end

      steps = generate_range_steps(from_date: from_date.to_date, to_date: to_date.to_date)
      initial_hash = steps.map do |step|
        {
          "date" => step,
          "count" => 0
        }
      end

      customers_hash =
        customers.
          select(Arel.sql(("#{grouping_statement} AS date, COUNT(accounts.id) AS count"))).
          group(Arel.sql(grouping_statement)).
          order(Arel.sql(grouping_statement)).
          as_json(except: ['id']).
          map { |customer| { "date" => customer['date'].to_time.utc.iso8601, "count" => customer['count'] } }

      customers_hash.each { |customer| initial_hash.delete_if { |hash| hash['date'] == customer['date'] } }

      (initial_hash + customers_hash).sort {|a, b| a["date"] <=> b["date"]}
    end
end
