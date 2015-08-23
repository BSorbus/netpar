class ExamPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index_l?
    user_activities.include? 'certificate_l:index'
  end

  def index_m?
    user_activities.include? 'certificate_m:index'
  end

  def index_r?
    user_activities.include? 'certificate_r:index'
  end

  def index?
    false
    #user_activities.include? 'exam:index'
  end

  def show_l?
    user_activities.include? 'certificate_l:show'
  end

  def show_m?
    user_activities.include? 'certificate_m:show'
  end

  def show_r?
    user_activities.include? 'certificate_r:show'
  end

  def show?
    false
    #user_activities.include? 'exam:show'
  end

  def new_l?
    user_activities.include? 'certificate_l:create'
  end

  def new_m?
    user_activities.include? 'certificate_m:create'
  end

  def new_r?
    user_activities.include? 'certificate_r:create'
  end

  def new?
    false
    #user_activities.include? 'exam:create'
    #user.admin? or user.power_user?
  end

  def create_l?
    new_l?
  end

  def create_m?
    new_m?
  end

  def create_r?
    new_r?
  end

  def create?
    new?
  end

  def edit_l?
    user_activities.include? 'certificate_l:update'
  end

  def edit_m?
    user_activities.include? 'certificate_m:update'
  end

  def edit_r?
    user_activities.include? 'certificate_r:update'
  end

  def edit?
    false
  end

  def update_l?
    edit_l?
  end

  def update_m?
    edit_m?
  end

  def update_r?
    edit_r?
  end

  def update?
    edit?
  end

  def destroy_l?
    user_activities.include? 'certificate_l:delete'
  end
 
  def destroy_m?
    user_activities.include? 'certificate_m:delete'
  end
 
  def destroy_r?
    user_activities.include? 'certificate_r:delete'
  end
 
  def destroy?
    false
  end
 
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end