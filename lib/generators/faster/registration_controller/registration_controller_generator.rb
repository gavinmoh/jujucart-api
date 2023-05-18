# frozen_string_literal: true

module Faster
  module Generators
    class RegistrationControllerGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path('templates', __dir__)

      check_class_collision suffix: "Controller"

      class_option :orm, banner: "NAME", type: :string, required: true,
                         desc: "ORM to generate the controller for"

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_parent_class_file
        unless class_path.empty? or class_exists?(parent_class_name)
          template 'application_controller.rb', File.join("app/controllers", controller_class_path, "application_controller.rb")
        end
      end

      def create_model_file
        if behavior == :invoke and current_user_scope and not class_exists?(current_user_scope.camelize)
          inside "app/models" do
            create_file "#{current_user_scope}.rb", <<-CODE
class #{current_user_scope.camelize} < Account
end  
CODE
          end
        end
      end

      def create_controller_file
        template 'registrations_controller.rb', File.join("app/controllers", controller_class_path, "#{controller_file_name}_controller.rb")
      end

      def add_devise_for
        route "devise_for :#{current_user_scope}s, only: [:passwords]"
      end

      def add_routes
        routing_code = <<-CODE
devise_scope :#{current_user_scope} do
  post '/', to: 'registrations#create'
end
CODE
        route routing_code, namespace: regular_class_path
      end
       
      def create_rswag_request_file
        template 'registration_spec.rb', File.join('spec', 'requests', "#{controller_path}_spec.rb")
      end

      def puts_message
        if behavior == :invoke
          puts "Remember to fix routes and add has_many to model"
        end
      end

      private
        def permitted_params
          attachments, others = attributes_names.partition { |name| attachments?(name) }
          params = others.map { |name| ":#{name}" }
          params += attachments.map { |name| "#{name}: []" }
          params.join(", ")
        end

        def attachments?(name)
          attribute = attributes.find { |attr| attr.name == name }
          attribute&.attachments?
        end

        def controller_path
          file_path.chomp('_controller')
        end

        def parent_class_name
          class_path.empty? ? 'ApplicationController' : "#{class_path.join('/').camelize}::ApplicationController"           
        end

        def current_user_scope
          unless class_path.empty?
            unless ['web', 'api', 'v1', 'application', 'public'].include?(class_path[-1])
              class_path[-1]
            else
              nil
            end
          else
            nil
          end
        end

        def class_exists?(class_name)
          klass = Module.const_get(class_name)
          return klass.is_a?(Class)
        rescue NameError
          return false
        end

        def rswag_tag_prefix
          unless class_path.empty?
            "#{class_path[-1].camelize} "
          else
            ""
          end          
        end
    end
  end
end