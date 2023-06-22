class Api::V1::User::InventoryTransferPolicy < ApplicationPolicy
  def update?
    @record.pending?
  end

  def destroy?
    @record.pending?
  end

  def transfer?
    true
  end

  def accept?
    true
  end

  def cancel?
    true
  end

  def revert?
    true
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
