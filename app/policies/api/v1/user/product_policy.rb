class Api::V1::User::ProductPolicy < ApplicationPolicy
  def import?
    true
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
