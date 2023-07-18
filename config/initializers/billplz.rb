require 'billplz'

Billplz.configure do |config|
  config.api_key         = ENV.fetch('BILLPLZ_API_KEY', nil)
  config.base_url        = ENV.fetch('BILLPLZ_BASE_URL', nil)
  config.x_signature_key = ENV.fetch('BILLPLZ_X_SIGNATURE_KEY', nil)
end
