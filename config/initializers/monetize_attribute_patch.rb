# This is to monkey patch column type 'monetize` as valid_type
# because a guy decided that in Rails 7,
# generators should raise an error if an attribute has an invalid type
# https://github.com/rails/rails/pull/42311

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def valid_type?(type)
        type.to_s == 'monetize' || super
      end
    end
  end
end