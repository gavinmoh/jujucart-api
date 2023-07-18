class Api::V1::Storefront::ApplicationController < ApplicationController
  before_action :set_store

  # define pundit user here if the default user object is not current_user
  def pundit_user
    PunditContext.new(current_customer, store: current_store, workspace: current_workspace)
  end

  def set_store
    @store = if request.headers["X-STORE-ID"].present?
               Store.online.find(request.headers["X-STORE-ID"])
             elsif request.host.ends_with?(".#{Setting.main_domain}")
               Store.online.find_by!(subdomain: request.subdomain)
             else
               Store.online.find_by!(hostname: request.host)
             end
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "Store not found",
      message: "Possible reasons: Store is not set as online store; X-STORE-ID header is missing; Store's hostname or subdomain is not set properly."
    }, status: :bad_request
  end

  def current_store
    @store
  end

  def current_workspace
    current_store.workspace
  end
end
