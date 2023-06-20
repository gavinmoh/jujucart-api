require 'revenue_monster'

RevenueMonster.configure do |config|
  # all available options, 
  # default values will be loaded from environment variables
  config.base_url = ENV['REVENUE_MONSTER_API_URL']
  config.oauth_url = ENV['REVENUE_MONSTER_OAUTH_URL']
  config.cache_store = Rails.cache
  # config.private_key = ENV['REVENUE_MONSTER_PRIVATE_KEY']
  # config.client_id = ENV['REVENUE_MONSTER_CLIENT_ID']
  # config.client_secret = ENV['REVENUE_MONSTER_CLIENT_SECRET']
end