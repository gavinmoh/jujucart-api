class Api::V1::User::WalletPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(workspace_id: @workspace.id)
    end
  end
end
