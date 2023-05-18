class ErrorResponse 

  def initialize(error)
    if error.is_a?(String)
      initialize_error_message(error)
    elsif error.is_a?(ActiveRecord::Base)
      initialize_object_error(error)
    else
      initialize_unknown_error
    end
  end

  def to_h
    { errors: @errors, errors_messages: @error_messages }
  end

  # def as_json
  #   to_h.as_json
  # end

  private
    def initialize_error_message(error)
      @error_messages = [error] 
      @errors = [{ attribute: nil, validation: nil, message: [error] }]
    end

    def initialize_object_error(object)
      if object.errors.any?
        @error_messages = object.errors.full_messages
        @errors = object.errors.map do |error|
          {
            attribute: error.attribute,
            validation: error.type,
            message: error.message
          }
        end
      else
        initialize_unknown_error
      end
    end

    def initialize_unknown_error
      @error_messages = ['Something went wrong']
      @errors = [{ attribute: nil, validation: nil, message: [@error_messages] }]
    end

end