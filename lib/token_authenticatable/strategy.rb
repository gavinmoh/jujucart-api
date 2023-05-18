require 'devise'

module TokenAuthenticatable
  class Strategy < Devise::Strategies::Authenticatable

    def valid?
      env['HTTP_AUTHORIZATION'].present?
    end

    def authenticate!
      return success!(warden_user)   if warden_user # check if user already set by another strategy
      return fail!(:unauthenticated) if !(session = Session.find_by(token: bearer_token, scope: scope.to_s))
      return fail!(:timeout)         if (session.revoked? or session.expired?)
      return fail!(:inactive)        if !session.account.active_for_authentication?
      return success!(session.account)
    end

    def store?
      false
    end

    private
      def bearer_token
        pattern = /^Bearer /
        header  = env['HTTP_AUTHORIZATION']
        if header && header.match(pattern)
          header.gsub(pattern, '') 
        else
          nil
        end
      end

      def warden_user
        env['warden'].user
      end
  end
end

Warden::Strategies.add(:token_authenticatable, TokenAuthenticatable::Strategy)