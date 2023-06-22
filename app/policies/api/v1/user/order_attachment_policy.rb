class Api::V1::User::OrderAttachmentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:order).where(order: { workspace_id: @workspace.id })
    end
  end
end
