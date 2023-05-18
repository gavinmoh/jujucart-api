require_relative 'token_authenticatable/strategy'
require_relative 'token_authenticatable/middlewares'
require_relative 'token_authenticatable/configuration'
require_relative 'token_authenticatable/hooks'

module TokenAuthenticatable
  def self.configuration
    @configuration ||= self::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end