require 'fcm'

FCM.configure do |config|
  config.project_id = ENV['FCM_PROJECT_ID']
  # config.base_url = "https://fcm.googleapis.com"
end