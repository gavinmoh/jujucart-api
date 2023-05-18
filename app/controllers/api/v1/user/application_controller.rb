class Api::V1::User::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit

  # define pundit user here if the default user object is not current_user
  def pundit_user
    current_user
  end

  def user_for_paper_trail
    current_user&.id
  end

  def info_for_paper_trail
    { 
      ip: request.remote_ip.to_s, 
      user_agent: request.user_agent,
      metadata: {
        account: {
          id: current_user&.id,
          name: current_user&.name,
          email: current_user&.email,
          phone_number: current_user&.phone_number,
          type: current_user&.type
        }
      } 
    }
  end
end
