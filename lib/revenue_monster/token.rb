class RevenueMonster::Token

  attr_accessor :access_token, :expires_in, :token_type, :refresh_token, :refresh_token_expires_in, :issued_at

  def initialize(hash)
    hash.each do |key, value|
      if key == 'issued_at'
        value.is_a?(Time) ? instance_variable_set("@#{key}", value) : instance_variable_set("@#{key}", Time.parse(value))
      else
        instance_variable_set("@#{key}", value)
      end
    end
  end

  def expired_at
    @issued_at + @expires_in
  end

  def refresh_token_expired_at
    @issued_at + @refresh_token_expires_in
  end

  def to_json(_options = nil)
    {
      access_token: @access_token,
      expires_in: @expires_in,
      token_type: @token_type,
      refresh_token: @refresh_token,
      refresh_token_expires_in: @refresh_token_expires_in,
      issued_at: @issued_at
    }.to_json
  end

  def expired?
    # buffer 10 minutes
    (Time.now + 10.minute) > expired_at
  end

  def valid?
    !expired?
  end

end