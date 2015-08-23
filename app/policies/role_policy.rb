class RolePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'role:index'
  end

  def show?
    user_activities.include? 'role:show'
  end

  def new?
    user_activities.include? 'role:create'
    #user.admin? or user.power_user?
  end

  def create?
    new?
  end

  def edit?
    user_activities.include? 'role:update'
    #user.admin? or user.power_user?
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'role:delete'
    #user.admin? or user.power_user?
  end
 
  def add_remove_role_user?
    user_activities.include? 'role:add_remove_user' or user_activities.include? 'user:add_remove_role'
    #user.admin? or user.power_user?
  end
 
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end