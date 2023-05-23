require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"
require 'csv'

# requiring middlewares
require_relative '../lib/token_authenticatable'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JujucartApi
  class Application < Rails::Application
    # injecting middlewares
    config.middleware.insert_before Warden::Manager, TokenAuthenticatable::Middlewares::SessionRevoker
    config.middleware.insert_before Warden::Manager, TokenAuthenticatable::Middlewares::TokenDispatcher

    # set timezone and let rails auto convert the timezone regardless of server time
    config.time_zone = "Kuala Lumpur"
      
    # use uuid as main primary key
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # config.session_store :cookie_store, key: '_interslice_session'
    # config.middleware.use ActionDispatch::Cookies
    # config.middleware.use config.session_store, config.session_options

    # shift to production.rb to be environment specific
    # active job to use sidekiq
    # config.active_job.queue_adapter = :sidekiq
  end
end
