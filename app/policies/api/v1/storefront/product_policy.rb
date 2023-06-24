class Api::V1::Storefront::ProductPolicy < ApplicationPolicy
  def all?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(workspace_id: @workspace.id, is_hidden: false, active: true)
           .with_store_quantity(@store.id, include_all_products: false)
    end
  end
end
