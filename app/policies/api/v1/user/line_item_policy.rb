class Api::V1::User::LineItemPolicy < ApplicationPolicy
  def create?
    @record.order.pos? and @record.order.pending?    
  end

  def update?
    @record.order.pos? and @record.order.pending?    
  end

  def destroy?
    @record.order.pos? and @record.order.pending?    
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
