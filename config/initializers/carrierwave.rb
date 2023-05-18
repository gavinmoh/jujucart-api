CarrierWave.configure do |config|
  config.cache_storage = :file

  if Rails.env.test?
    config.enable_processing = false if Rails.env.test?
    config.asset_host = 'http://example.com'
  elsif ENV['USE_LOCAL_FILE_STORAGE'].present?
    config.storage = :file
    config.asset_host = ENV['ASSET_HOST']
  else
    config.storage = :fog
    config.fog_credentials = {
      provider:              'AWS',                        
      aws_access_key_id:     ENV['S3_KEY'],                
      aws_secret_access_key: ENV['S3_SECRET'],             
      region:                ENV['S3_REGION']
    }
    config.fog_directory  = ENV['S3_BUCKET_NAME']
    config.fog_public     = true 
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end
end
