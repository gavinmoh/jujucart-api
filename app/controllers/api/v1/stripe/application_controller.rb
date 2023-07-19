class Api::V1::Stripe::ApplicationController < ApplicationController
  before_action { |_controller| @callback_from = 'Stripe' }
  include CallbackLoggable

  def callback
    head :ok
  end
end
