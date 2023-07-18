class ApplicationController < ActionController::API
  include Pagy::Backend
  include Pundit::Authorization
  include Filterable

  after_action { pagy_headers_merge(@pagy) if @pagy }

  rescue_from Pundit::NotAuthorizedError, with: lambda {
    render json: { message: "You are not allowed to access this resource or perform this action." }, status: :forbidden
  }
  rescue_from ActiveRecord::RecordNotFound, with: lambda {
    render json: { message: "Resource not found. Wrong id?" }, status: :not_found
  }
  rescue_from ActionController::ParameterMissing, with: lambda {
    render json: { message: "Required param(s) is missing." }, status: :bad_request
  }
  rescue_from ActionController::RoutingError, with: lambda {
    render json: { message: "The path not found." }, status: :bad_request
  }
  rescue_from Pagy::VariableError, with: lambda {
    render json: { message: "Page number error." }, status: :bad_request
  }
end
