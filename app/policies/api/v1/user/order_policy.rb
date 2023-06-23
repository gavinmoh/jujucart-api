class Api::V1::User::OrderPolicy < ApplicationPolicy

  def index?
    true
  end

  def export?
    true
  end

  def show?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def create?
    if @user.admin?
      @record.pos? and @record.pending?
    elsif @user.cashier?
      @record.pos? and @record.pending? and @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def update?
    if @user.admin?
      true
    elsif @user.cashier?
      @record.pos? and @record.pending? and @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def destroy?
    @record.pending? and @user.admin?
  end

  def complete?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def checkout?
    if @user.admin?
      true
    elsif @user.cashier?
      @record.pos? and @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def pack?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def ship?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def void?
    @user.admin?
  end

  def versions?
    @user.admin?
  end

  def apply_coupon?
    if @user.admin?
      true
    elsif @user.cashier?
      @record.pos? and @record.pending? and @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def remove_coupon?
    if @user.admin?
      true
    elsif @user.cashier?
      @record.pos? and @record.pending? and @user.assigned_stores.exists?(store_id: @record.store_id)
    end
  end

  def bulk_pack?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.pluck(:store_id).uniq)
    end
  end

  def bulk_confirm?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.pluck(:store_id).uniq)
    end
  end

  def bulk_complete?
    if @user.admin?
      true
    elsif @user.cashier?
      @user.assigned_stores.exists?(store_id: @record.pluck(:store_id).uniq)
    end
  end

  def bulk_void?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        scope.all
      else
        scope.where(store_id: @user.assigned_stores.pluck(:store_id))
      end
    end
  end
end
