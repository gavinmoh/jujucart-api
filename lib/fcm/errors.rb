module FCM
  class PayloadRequiredError < StandardError 
    def initialize(msg="Payload is required")
      super
    end
  end
end