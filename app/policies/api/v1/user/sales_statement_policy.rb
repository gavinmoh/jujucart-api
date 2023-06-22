class Api::V1::User::SalesStatementPolicy < ApplicationPolicy
  def index?
    @user.admin?
  end

  def pdf?
    @user.admin?
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
