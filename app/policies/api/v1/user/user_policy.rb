class Api::V1::User::UserPolicy < ApplicationPolicy
  def create?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def destroy?
    @user.admin?
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:user_workspaces).where(user_workspaces: { workspace_id: @workspace.id })
    end
  end
end
