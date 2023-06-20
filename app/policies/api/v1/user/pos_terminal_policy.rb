class Api::V1::User::PosTerminalPolicy < ApplicationPolicy
  def initiate_payment?
    true
  end

  def cancel_payment?
    true
  end

  def card_payment_refund?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
