class ApplicationPolicy
  attr_reader :user, :record

  def initialize(context, record)
    if context.class == PunditContext
      @user = context.user
      @workspace = context.workspace
    else
      @user = context
    end
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  class Scope
    attr_reader :user, :scope

    def initialize(context, scope)
      if context.class == PunditContext
        @user = context.user
        @workspace = context.workspace
      else
        @user = context
      end
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
