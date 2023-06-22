class Api::V1::User::PaymentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
