class Api::V1::User::InventoryTransactionPolicy < ApplicationPolicy
  def adjustment?
    true
  end
  
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:inventory).where(inventory: {workspace_id: @workspace.id})
    end
  end
end
