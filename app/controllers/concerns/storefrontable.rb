module Storefrontable
  extend ActiveSupport::Concern

  included do
    before_action :set_store
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
