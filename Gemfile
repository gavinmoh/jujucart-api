source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.3"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "letter_opener", group: :development
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rswag-specs'
end

group :development do
  gem 'railroady'
end

group :test do
  gem "simplecov", require: false
  gem "bullet"
  gem "rspec-sidekiq", "~> 3.1"
  gem "shoulda-matchers"
  
  # only enable if it is necessary
  gem "webmock", "~> 3.14"
  gem "sinatra", "~> 2.2"
end

group :production do
  gem "cloudflare-rails"
  gem "elastic-apm"

  # drop-in replacement for websocket
  # gem "anycable-rails", "~> 1.1"
end

# cors for api app
gem "rack-cors"

# dummy data generator
gem 'faker'
gem 'factory_bot_rails'

# authentication
gem 'devise'
# gem "devise-jwt", "~> 0.6.0"
# gem 'warden-jwt_auth', '0.4.2' # latest version doesn't work well with devise-jwt

# authorization
gem 'pundit'

# pagination
gem "pagy"

# database view
gem "scenic"

# background processing
gem "sidekiq"
gem "sidekiq-scheduler", "~> 3.0"

# handling currency
gem "money-rails"

# use interactor pattern for complex workflow
gem "interactor-rails", "~> 2.2"

# application settings
gem "rails-settings-cached", "~> 2.0"

# view layer of JSON API
gem "active_model_serializers", "~> 0.10.10"

# file upload & processing
gem "fog-aws", "~> 3.6"
gem "carrierwave", "~> 2.1"
gem "carrierwave-base64", "~> 2.8"
gem "file_validators", "~> 2.3"

# only needed for csv processing
# gem "smarter_csv", "~> 1.2"

# state machine
gem "aasm", "~> 5.1"

# geolocation gem
gem "geocoder"

# PDF gems
# gem "wicked_pdf", "~> 2.1"
# gem 'wkhtmltopdf-binary', '~> 0.12.6.5'
# gem "combine_pdf", "~> 1.0"

# record tracking
gem "paper_trail"

# linter and syntax checking
gem "rubocop-rails", "~> 2.13"

# vulnerability scanning
gem "brakeman", "~> 5.2"

# env variables loading
gem "dotenv-rails", "~> 2.7"
gem "noticed", "~> 1.6"

gem "nanoid", "~> 2.0"

gem "googleauth"
gem "faraday"

gem "wicked_pdf", "~> 2.6"

gem "wkhtmltopdf-binary", "~> 0.12.6"
