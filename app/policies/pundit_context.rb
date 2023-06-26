class PunditContext
  attr_reader :user, :workspace, :store

  def initialize(user, opt = {})
    @user = user
    @store = opt[:store]
    @workspace = opt[:workspace]
  end
  
end