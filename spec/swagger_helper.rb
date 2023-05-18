# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('public').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Jujucart API V1',
        version: "v1 Build #{Time.current.strftime('%Y%m%d%H%M')}"
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      # 'x-tagGroups': [
      #   { name: 'Admin', tags: ['Admin Sessions', 'Admin Accounts', 'Admin Reset Passwords','Admin Settings'] }
      # ],
      components: {
        securitySchemes: {
          bearerAuth: {
            description: "The bearer token is returned in Authorization header upon successful sign in",
            type: 'http',
            scheme: 'bearer'
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json

  # adapted from https://github.com/rswag/rswag/issues/146#issuecomment-444238097
  config.after do |example|
    # callback to save response examples
    if example.metadata[:response] && !['204', '301', '302'].include?(example.metadata[:response][:code].to_s)
      begin 
        parsed = JSON.parse(response.body, symbolize_names: true)
        content = example.metadata[:response][:content] || {}
        example_spec = {
          "application/json"=>{
            examples: {
              test_example: {
                value: parsed
              }
            }
          }
        }
        example.metadata[:response][:content] = content.deep_merge(example_spec)
      rescue JSON::ParserError
        # do nothing
      end
    end
    # example.metadata[:response][:examples] = { "application/json" => JSON.parse(response.body, symbolize_names: true) }
    
    # helper method to save request examples
    request_example_name = example.metadata[:save_request_example]
    if request_example_name && respond_to?(request_example_name)
      param = example.metadata[:operation][:parameters].detect { |p| p[:name] == request_example_name }
      param[:schema][:example] = send(request_example_name)
    end
  end
end