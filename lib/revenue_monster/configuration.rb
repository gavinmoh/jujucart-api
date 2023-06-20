module RevenueMonster
  class Configuration
    attr_accessor :base_url, :oauth_url, :private_key, 
                  :client_id, :client_secret, :server_public_key, 
                  :cache_store

    def initialize(
      base_url:      "https://open.revenuemonster.my", 
      oauth_url:     "https://oauth.revenuemonster.my",
      private_key:   ENV["REVENUE_MONSTER_PRIVATE_KEY"], 
      client_id:     ENV["REVENUE_MONSTER_CLIENT_ID"], 
      client_secret: ENV["REVENUE_MONSTER_CLIENT_SECRET"],
      server_public_key: ENV["REVENUE_MONSTER_SERVER_PUBLIC_KEY"],
      cache_store:   nil
    )
      @base_url = base_url.end_with?("/") ? base_url[0..-2] : base_url
      @oauth_url = oauth_url.end_with?("/") ? oauth_url[0..-2] : oauth_url
      @private_key = private_key&.gsub(/\\n/, "\n")
      @client_id = client_id
      @client_secret = client_secret
      @server_public_key = server_public_key&.gsub(/\\n/, "\n")
      @cache_store = cache_store
    end

    
  end
end