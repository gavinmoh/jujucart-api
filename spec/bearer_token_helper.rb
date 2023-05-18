module BearerTokenHelper
  def bearer_token_for(user)
    session = Session.create(account: user, scope: user.class.name.downcase)
    "Bearer #{session.token}"
  end
end