class Api::V1::User::SettingPolicy < ApplicationPolicy
  def update?
    @user.admin?
  end
end
