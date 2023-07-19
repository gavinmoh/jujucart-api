class Api::V1::User::StripeController < Api::V1::User::ApplicationController
  def connect
    if current_workspace.stripe_account_id.blank?
      @stripe_account = Stripe::Account.create(
        {
          type: 'standard',
          country: 'MY',
          email: current_user.email,
          capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true }
          }
        }
      )

      current_workspace.update(
        stripe_account_id: @stripe_account.id
      )
    end

    if @stripe_account.present? || params[:refresh].present?
      @link = Stripe::AccountLink.create(
        {
          account: current_workspace.stripe_account_id,
          refresh_url: "#{Setting.web_host}/stripe/connect?refresh=true",
          return_url: "#{Setting.web_host}/stripe/connected",
          type: 'account_onboarding'
        }
      )
      render json: { onboarding_link: @link }
      return
    end

    render json: ErrorResponse.new("Already connected"), status: :bad_request
  end
end
