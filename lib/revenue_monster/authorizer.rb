class RevenueMonster::Authorizer

  def self.endpoint
    "#{self.module_parent.configuration.oauth_url}/v1/token"
  end

  def self.base64_credential
    Base64.strict_encode64("#{self.module_parent.configuration.client_id}:#{self.module_parent.configuration.client_secret}")
  end

  def self.get_token
    token = fetch_cached_token
    return token if token.present? && token.valid?
    token = fetch_token
    cache_token(token)
    token
  end

  def self.fetch_token
    response = module_parent.base_request.post do |req|
      req.url endpoint
      req.headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Basic #{base64_credential}"
      }
      req.body = { grantType: 'client_credentials' }.to_json
    end
    raise module_parent::AuthorizationError.new(response.body) unless response.success?
    parsed_response = JSON.parse(response.body)
    module_parent::Token.new(
      access_token: parsed_response['accessToken'],
      expires_in: parsed_response['expiresIn'],
      refresh_token: parsed_response['refreshToken'],
      refresh_token_expires_in: parsed_response['refreshTokenExpiresIn'],
      token_type: parsed_response['tokenType'],
      issued_at: Time.now
    )
  end

  def self.cache_token(token)
    return unless cache_token?
    module_parent.configuration.cache_store.write('revenue_monster_token', token.to_json)
  end

  def self.fetch_cached_token
    return unless cache_token?
    json_token = module_parent.configuration.cache_store.fetch('revenue_monster_token')
    begin
      module_parent::Token.new(JSON.parse(json_token)) if json_token.present?
    rescue 
      nil
    end
  end

  def self.cache_token?
    module_parent.configuration.cache_store.present?
  end
  

end