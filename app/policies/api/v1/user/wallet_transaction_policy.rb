class Api::V1::User::WalletTransactionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:wallet).where(wallet: { workspace_id: @workspace.id })
    end
  end
end
