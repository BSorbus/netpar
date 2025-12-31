class ExamFeePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'exam_fee:index'
  end

  def show?
    user_activities.include? 'exam_fee:show'
  end

  def new?
    user_activities.include? 'exam_fee:create'
    #user.admin? or user.power_user?
  end

  def create?
    new?
  end

  def edit?
    user_activities.include? 'exam_fee:update'
    #user.admin? or user.power_user?
  end

  def update?
    edit?
  end

  def destroy?
    user_activities.include? 'exam_fee:delete'
    #user.admin? or user.power_user?
  end
 
  def work?
    user_activities.include? 'exam_fee:work'
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end