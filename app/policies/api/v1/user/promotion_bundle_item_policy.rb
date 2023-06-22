class Api::V1::User::PromotionBundleItemPolicy < ApplicationPolicy
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
      scope.joins(:promotion_bundle).where(promotion_bundle: { workspace_id: @workspace.id })
    end
  end
end
