class Api::V1::Storefront::LineItemPolicy < ApplicationPolicy
  def create?
    return false if @user.present? && @record.order.customer_id != @user.id

    @record.order.pending?
  end

  def update?
    return false if @user.present? && @record.order.customer_id != @user.id

    @record.order.pending?
  end

  def destroy?
    return false if @user.present? && @record.order.customer_id != @user.id

    @record.order.pending?
  end

  class Scope < Scope
    def resolve
      scope.joins(:order).where(order: { customer_id: @user&.id })
    end
  end
end
