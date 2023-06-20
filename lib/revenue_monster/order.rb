class RevenueMonster::Order

  def initialize(id:, amount:, title:, details:, additional_data:, currency_type: "MYR")
    @id = id
    @amount = amount
    @title = title
    @details = details
    @additional_data = @additionalData = additional_data
    @currency_type = @currencyType = currency_type

    raise self.class.module_parent::ArgumentError.new("Order id cannot be more than 24 characters") if @id.length > 24
    raise self.class.module_parent::ArgumentError.new("Order title cannot be more than 32 characters") if @title.length > 32
    raise self.class.module_parent::ArgumentError.new("Order amount must be an integer") unless @amount.is_a?(Integer)
    raise self.class.module_parent::ArgumentError.new("Order details cannot be more than 600 characters") if @details.length > 600
    raise self.class.module_parent::ArgumentError.new("Order additional data cannot be more than 128 characters") if @additional_data.length > 128
    raise self.class.module_parent::ArgumentError.new("Order currency type must be MYR") unless @currency_type == "MYR"
  end

  def as_json(options = {})
    super(options.merge(only: %w[id amount title details additionalData currencyType]))
  end

end