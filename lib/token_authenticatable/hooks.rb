require 'warden/manager'

module TokenAuthenticatable
  class Hooks

    def self.after_set_user(user, auth, opts)
      new.send(:create_session, user, auth, opts)
    end

    private
      def create_session(user, auth, opts)
        env = auth.env
        scope = opts[:scope]
        request = ActionDispatch::Request.new env
        if user && create_session?(request)
          # create a new session if user is authenticated
          session = user.sessions.create(
            scope: scope,
            expired_at: token_expires_in,
            user_agent: request.user_agent,
            remote_ip: request.remote_ip,
            referer: request.referer
          )
          env['token_authenticatable.token'] = session.token
        end
      end

      def token_expires_in
        (expires_in = self.class.module_parent.configuration.token_expires_in) ? Time.now + expires_in : nil
      end

      def create_session?(request)
        self.class.module_parent.configuration.creator_requests.each do |matcher|
          request_method, regex = matcher 
          return true if request_method == request.method && request.path.match(regex)
        end
        return false
      end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  TokenAuthenticatable::Hooks.after_set_user(user, auth, opts)
end