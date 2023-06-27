CarrierWave.configure do |config|
  config.cache_storage = :file
  config.cache_dir = Rails.root.join('tmp/uploads')

  if Rails.env.test?
    config.enable_processing = false if Rails.env.test?
    config.asset_host = 'http://example.com'
  elsif ENV['USE_LOCAL_FILE_STORAGE'].present?
    config.storage = :file
    config.asset_host = ENV.fetch('ASSET_HOST', nil)
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV.fetch('S3_KEY', nil),
      aws_secret_access_key: ENV.fetch('S3_SECRET', nil),
      region: ENV.fetch('S3_REGION', nil)
    }
    config.fog_directory  = ENV.fetch('S3_BUCKET_NAME', nil)
    config.fog_public     = true
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end
end
