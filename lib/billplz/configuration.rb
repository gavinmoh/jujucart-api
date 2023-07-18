module Billplz
  class Configuration
    attr_accessor :base_url, :api_key, :x_signature_key

    def initialize(base_url: "https://www.billplz.com", api_key: nil, x_signature_key: nil)
      @base_url = base_url
      @api_key = api_key
      @x_signature_key = x_signature_key
    end
  end
end
