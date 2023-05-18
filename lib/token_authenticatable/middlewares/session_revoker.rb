module TokenAuthenticatable
  module Middlewares
    class SessionRevoker
    
      def initialize(app)
        @app = app
      end
    
      def call(env)
        request = ActionDispatch::Request.new env
    
        status, headers, response = @app.call(env)
    
        if revoke_session?(request)
          token = bearer_token(request)
          session = Session.find_by(token: token)
          session&.revoke!
        end
    
        return [status, headers, response]
      end
    
      def bearer_token(request)
        pattern = /^Bearer /
        header  = request.headers['Authorization']
        if header && header.match(pattern)
          header.gsub(pattern, '') 
        else
          nil
        end
      end

      def revoke_session?(request)
        self.class.module_parent.module_parent.configuration.revoker_requests.each do |matcher|
          request_method, regex = matcher 
          return true if request_method == request.method && request.path.match(regex)
        end
        return false
      end
    end
  end
end

