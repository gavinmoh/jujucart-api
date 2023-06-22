class Api::V1::User::LocationPolicy < ApplicationPolicy
  def update?
    @record.store.nil?
  end

  def destroy?
    @record.store.nil?
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
