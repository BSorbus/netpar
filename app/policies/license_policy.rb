class LicensePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'license:index'
  end

  def show?
    user_activities.include? 'license:show'
  end

  def new?
    user_activities.include? 'license:create'
    #user.admin? or user.power_user?
  end

  def create?
    new?
  end

  def edit?
    user_activities.include? 'license:update'
    #user.admin? or user.power_user?
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'license:delete'
    #user.admin? or user.power_user?
  end
 
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end