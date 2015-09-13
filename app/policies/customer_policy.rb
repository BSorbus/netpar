class CustomerPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'customer:index'
  end

  def merge?
    user_activities.include? 'customer:merge'
  end

  def show?
    user_activities.include? 'customer:show'
  end

  def new?
    user_activities.include? 'customer:create'
    #user.admin? or user.power_user?
  end

  def create?
    new?
  end

  def edit?
    user_activities.include? 'customer:update'
    #user.admin? or user.power_user?
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'customer:delete'
    #user.admin? or user.power_user?
  end
 
  def work?
    user_activities.include? 'customer:work'
  end

 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end