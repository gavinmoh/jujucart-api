# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :web_host, default: "https://www.jujucart.com", type: :string

  field :google_bearer_token, default: "", type: :string
  field :google_bearer_token_expired_at, default: nil, type: :datetime
  field :coin_to_cash_rate, default: 0.01, type: :float
  field :order_reward_amount, default: 0, type: :integer
  field :maximum_redeemed_coin_rate, default: 0.5, type: :float
end
