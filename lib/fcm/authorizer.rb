module FCM
  class Authorizer
    # these ENV vars must be set in the environment
    # "GOOGLE_CLIENT_ID",
    # "GOOGLE_CLIENT_EMAIL",
    # "GOOGLE_ACCOUNT_TYPE", 
    # "GOOGLE_PRIVATE_KEY"
    AUTH_SCOPE   = "https://www.googleapis.com/auth/firebase.messaging".freeze

    def self.get_token
      if setting_store_exists?
        if get_token_from_setting_store and 
            get_token_expired_at_from_setting_store and 
            get_token_expired_at_from_setting_store >= (Time.current - 10.minute)
          get_token_from_setting_store
        else
          fetch_token
        end
      else
        fetch_token
      end          
    end

    def self.fetch_token
      creds = Google::Auth::ServiceAccountCredentials.make_creds(scope: AUTH_SCOPE)
      creds.fetch_access_token!
      store_token(creds)
      creds.access_token
    end

    def self.store_token(creds)
      return unless setting_store_exists?
      Setting.google_bearer_token = creds.access_token if Setting.respond_to?(:google_bearer_token)
      Setting.google_bearer_token_expired_at = (Time.current + creds.expires_in.second) if Setting.respond_to?(:google_bearer_token)
    end

    def self.setting_store_exists?
      Module.const_get('Setting').present? rescue false
    end

    def self.get_token_from_setting_store
      if setting_store_exists? and Setting.respond_to?(:google_bearer_token)
        Setting.google_bearer_token 
      else
        nil
      end
    end

    def self.get_token_expired_at_from_setting_store
      if setting_store_exists? and Setting.respond_to?(:google_bearer_token_expired_at)
        Setting.google_bearer_token_expired_at 
      else
        nil
      end
    end
  end
end