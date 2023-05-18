module TokenAuthenticatable
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc "Install TokenAuthenticatable into your application"
      argument :name, type: :string, default: "account", banner: "user model name"      
    
      def copy_initializer
        template "initializer.rb", "config/initializers/token_authenticatable.rb"
      end
    
      def copy_session_model
        template "model.rb", "app/models/session.rb"
      end
    
      def copy_migration
        template "migration.rb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_sessions.rb"
      end

      def inject_middlewares
        inject_into_file "config/application.rb", before: /^Bundler/ do
          # straight out using require_relative wont work
          "require_relative_replace_me_ '../lib/token_authenticatable'\n\n"
        end

        gsub_file 'config/application.rb', 'require_relative_replace_me_', 'require_relative'

        application do
          "config.middleware.insert_before Warden::Manager, TokenAuthenticatable::Middlewares::TokenDispatcher"
        end
        
        application do
          "config.middleware.insert_before Warden::Manager, TokenAuthenticatable::Middlewares::SessionRevoker"
        end
      end

      def user_model_name
        options[:name]&.downcase || "account"
      end
    end
  end
end
