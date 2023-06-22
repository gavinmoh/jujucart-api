class PunditContext
  attr_reader :user, :workspace

  def initialize(user, workspace=nil)
    @user = user
    @workspace = workspace
  end
  
end