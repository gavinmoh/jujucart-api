# frozen_string_literal: true

module Faster
  module Generators
    class ScaffoldControllerGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path('templates', __dir__)

      check_class_collision suffix: "Controller"

      class_option :orm, banner: "NAME", type: :string, required: true,
                         desc: "ORM to generate the controller for"

      class_option :skip_pundit, type: :boolean, desc: "Don't add pundit code (authorization)."

      class_option :parent_resource, banner: "PARENT_RESOURCE", type: :string, required: false,
                          desc: "Nested under parent resource"

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_parent_class_file
        unless class_path.empty? or class_exists?(parent_class_name)
          template 'application_controller.rb', File.join("app/controllers", controller_class_path, "application_controller.rb")
        end
      end

      def create_user_scope_model_file
        if current_user_scope and not class_exists?(current_user_scope.camelize)
          inside "app/models" do
            create_file "#{current_user_scope}.rb", <<-CODE
class #{current_user_scope.camelize} < Account
end  
CODE
          end
        end
      end

      def create_controller_file
        template 'api_controller.rb', File.join("app/controllers", controller_class_path, "#{controller_file_name}_controller.rb")
      end

      invoke :serializer
      invoke :resource_route

      def invoke_pundit
        unless skip_pundit?
          invoke 'pundit:policy'
        end 
      end
       
      def create_rswag_request_file
        template 'rswag_spec.rb', File.join('spec', 'requests', "#{controller_path}_spec.rb")
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

        def skip_pundit?
          options.skip_pundit? || (not current_user_scope)
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

        def parent_resource
          if options.parent_resource
            options.parent_resource.singularize
          else
            nil
          end
        end

        def parent_resource_policy_scope_class_name
          "#{class_path.join('/').camelize}::#{parent_resource.camelize}Policy::Scope"          
        end

        def parent_resource_policy_class_name
          "#{class_path.join('/').camelize}::#{parent_resource.camelize}Policy"          
        end

        def policy_class_name
          "#{class_path.join('/').camelize}::#{singular_name.camelize}Policy"
        end

        def policy_scope_class_name
          "#{class_path.join('/').camelize}::#{singular_name.camelize}Policy::Scope"
        end

        def rswag_request_path
          if options.parent_resource
            "#{class_path.join('/')}/#{parent_resource.pluralize}/{#{parent_resource}_id}/#{plural_name}"
          else
            controller_class_name.underscore
          end
        end

        def rswag_tag_prefix
          unless class_path.empty?
            "#{class_path[-1].camelize} "
          else
            ""
          end          
        end

        def class_exists?(class_name)
          klass = Module.const_get(class_name)
          return klass.is_a?(Class)
        rescue NameError
          return false
        end
    end
  end
end