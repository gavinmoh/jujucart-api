# frozen_string_literal: true

module Faster
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      class_option :no_skip_model_namespace, type: :boolean, default: false

      def invoke_active_record
        if @options[:no_skip_model_namespace]
          invoke :model
        else
          if ARGV.empty?
            invoke :model, [singular_name]
          else
            invoke(:model, ARGV.map.with_index { |x, index| index == 0 ? singular_name : x })
          end
        end
      end

      hook_for :scaffold_controller, in: :faster, as: :scaffold_controller
    end
  end
end