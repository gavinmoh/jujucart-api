module RevenueMonster
  class AuthorizationError < StandardError 
    def initialize(msg="Fail to get access token")
      super
    end
  end

  class ArgumentError < StandardError
    def initialize(msg="Invalid argument")
      super
    end
  end

  class RequestTimeoutError < StandardError
    def initialize(msg="Request timeout")
      super
    end
  end

  class TerminalNotReachableError < StandardError
    def initialize(msg="Terminal not reachable")
      super
    end
  end

  class RequestError < StandardError
    def initialize(msg="Request error")
      super
    end
  end
end