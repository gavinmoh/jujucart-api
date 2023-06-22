class Api::V1::Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!
  # define pundit user here if the default user object is not current_user
  def pundit_user
    current_admin
  end
end
