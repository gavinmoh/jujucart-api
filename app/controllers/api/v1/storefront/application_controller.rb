class Api::V1::Storefront::ApplicationController < ApplicationController
  include Storefrontable

  # define pundit user here if the default user object is not current_user
  def pundit_user
    PunditContext.new(current_customer, store: current_store, workspace: current_workspace)
  end
end
