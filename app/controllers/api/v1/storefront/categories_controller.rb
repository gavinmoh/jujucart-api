class Api::V1::Storefront::CategoriesController < Api::V1::Storefront::ApplicationController
  before_action :set_categories, only: [:index]

  def index
    render json: @categories, adapter: :json
  end

  private

    def set_categories
      @categories = pundit_scope(Category.all).order(display_order: :asc)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Storefront::CategoryPolicy::Scope)
    end
end
