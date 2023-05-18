require 'fcm/configuration'
require 'fcm/client'
require 'fcm/authorizer'
require 'fcm/errors'

module FCM
  def self.configuration
    @configuration ||= self::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.base_request
    parsed = URI.parse(configuration.base_url)
    @base_request ||= Faraday.new(url: "#{parsed.scheme}://#{parsed.host}")
  end

  def self.auth_token
    self::Authorizer.get_token
  end
end