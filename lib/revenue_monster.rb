require 'revenue_monster/configuration'
require 'revenue_monster/signature'
require 'revenue_monster/authorizer'
require 'revenue_monster/errors'
require 'revenue_monster/token'
require 'revenue_monster/rsa'
require 'revenue_monster/terminal'
require 'revenue_monster/order'

module RevenueMonster

  SIGNATURE_TYPE = 'sha256' # it's only sha256 based on their documentation

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.base_request
    parsed = URI.parse(configuration.base_url)
    @base_request ||= Faraday.new(url: "#{parsed.scheme}://#{parsed.host}")
  end

end