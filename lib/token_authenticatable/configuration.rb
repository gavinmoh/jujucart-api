module TokenAuthenticatable
  class Configuration
    attr_accessor :token_expires_in, :creator_requests, :revoker_requests

    def initialize(token_expires_in: nil, creator_requests: [], revoker_requests: [])
      @token_expires_in = token_expires_in
      @creator_requests = creator_requests
      @revoker_requests = revoker_requests
    end
  end
end