module TokenAuthenticatable
  module Middlewares
    class TokenDispatcher
      def initialize(app)
        @app = app
      end
    
      def call(env)
        request = ActionDispatch::Request.new env
    
        status, headers, response = @app.call(env)

        token = env['token_authenticatable.token']
        
        if dispatch_token?(request) && token
          headers['Authorization'] = "Bearer #{token}"
        end
    
        return [status, headers, response]
      end

      private

        def dispatch_token?(request)
          self.class.module_parent.module_parent.configuration.creator_requests.each do |matcher|
            request_method, regex = matcher 
            return true if request_method == request.method && request.path.match(regex)
          end
          return false
        end
    end
  end
end

