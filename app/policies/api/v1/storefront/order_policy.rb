class Api::V1::Storefront::OrderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    if @user.present?
      @order.customer_id == @user.id
    else
      (@record.delivery? or @record.pickup?) and @record.customer_id.nil?
    end
  end

  def create?
    return false if @user.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  def update?
    return false unless @record.pending?
    return false if @user.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  def destroy?
    return false unless @record.pending?
    return false if @user.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  def complete?
    return false if @user.blank?

    @record.customer_id == @user.id
  end

  def checkout?
    return false if @record.customer_id.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  def apply_coupon?
    return false unless @record.pending?
    return false if @record.customer_id.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  def remove_coupon?
    return false unless @record.pending?
    return false if @record.customer_id.present? && @record.customer_id != @user&.id

    @record.delivery? or @record.pickup?
  end

  class Scope < Scope
    def resolve
      scope.where(customer_id: @user&.id, workspace_id: @workspace.id)
    end
  end
end
