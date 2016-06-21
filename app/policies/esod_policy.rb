class EsodPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    #raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'esod:index'
  end

  def show?
    user_activities.include? 'esod:show'
  end

  def new?
    user_activities.include? 'esod:create'
    #user.admin? or user.power_user?
  end

  def create?
    new?
  end

  def edit?
    user_activities.include? 'esod:update'
    #user.admin? or user.power_user?
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'esod:delete'
    #user.admin? or user.power_user?
  end
 
  def link?
    user_activities.include? 'esod:link'
  end
 
  def work?
    user_activities.include? 'esod:work'
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end