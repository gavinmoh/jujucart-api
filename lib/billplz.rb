require 'billplz/configuration'
require 'billplz/collection'
require 'billplz/bill'
require 'billplz/signature'

module Billplz
  def self.configuration
    @configuration ||= self::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.base_request
    parsed = URI.parse(configuration.base_url)
    auth = Base64.encode64("#{configuration.api_key}:")

    @base_request ||= Faraday.new(
      url: "#{parsed.scheme}://#{parsed.host}",
      headers: {
        "Authorization": "Basic #{auth}",
        "Content-Type": "application/json"
      }
    )
  end
end