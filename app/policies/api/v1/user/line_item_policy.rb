class Api::V1::User::LineItemPolicy < ApplicationPolicy
  def create?
    return true if @record.order.manual?
    return true if @record.order.pos? and @record.order.pending?
    false
  end

  def update?
    return true if @record.order.manual?
    return true if @record.order.pos? and @record.order.pending?
    false
  end

  def destroy?
    (@record.order.pos? or @record.order.manual?) and @record.order.pending?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
