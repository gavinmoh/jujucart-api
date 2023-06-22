class Api::V1::User::WorkspacePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    @record.owner == @user
  end
end
