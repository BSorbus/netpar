class ExaminationPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index_l?
    user_activities.include? 'examination_l:index'
  end

  def index_m?
    user_activities.include? 'examination_m:index'
  end

  def index_r?
    user_activities.include? 'examination_r:index'
  end

  def index?
    false
    #user_activities.include? 'examination:index'
  end

  def show_l?
    user_activities.include? 'examination_l:show'
  end

  def show_m?
    user_activities.include? 'examination_m:show'
  end

  def show_r?
    user_activities.include? 'examination_r:show'
  end

  def show?
    false
    #user_activities.include? 'examination:show'
  end

  def new_l?
    user_activities.include? 'examination_l:create'
  end

  def new_m?
    user_activities.include? 'examination_m:create'
  end

  def new_r?
    user_activities.include? 'examination_r:create'
  end

  def new?
    false
    #user_activities.include? 'examination:create'
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
    user_activities.include? 'examination_l:update'
  end

  def edit_m?
    user_activities.include? 'examination_m:update'
  end

  def edit_r?
    user_activities.include? 'examination_r:update'
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
    user_activities.include? 'examination_l:delete'
  end
 
  def destroy_m?
    user_activities.include? 'examination_m:delete'
  end
 
  def destroy_r?
    user_activities.include? 'examination_r:delete'
  end
 
  def destroy?
    false
  end
 
  def print_l?
    user_activities.include? 'examination_l:print'
  end

  def print_m?
    user_activities.include? 'examination_m:print'
  end

  def print_r?
    user_activities.include? 'examination_r:print'
  end
 
  def work_l?
    user_activities.include? 'examination_l:work'
  end

  def work_m?
    user_activities.include? 'examination_m:work'
  end

  def work_r?
    user_activities.include? 'examination_r:work'
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end