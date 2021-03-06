class CertificatePolicy < ApplicationPolicy
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
    #false
    user_activities.include? 'certificate_l:index' and user_activities.include? 'certificate_m:index' and user_activities.include? 'certificate_r:index'
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
    #user.admin? or user.power_user?
  end
 
  def destroy_m?
    user_activities.include? 'certificate_m:delete'
    #user.admin? or user.power_user?
  end
 
  def destroy_r?
    user_activities.include? 'certificate_r:delete'
    #user.admin? or user.power_user?
  end
 
  def destroy?
    false
  end

  def print_l?
    user_activities.include? 'certificate_l:print'
  end

  def print_m?
    user_activities.include? 'certificate_m:print'
  end

  def print_r?
    user_activities.include? 'certificate_r:print'
  end
 
 
  def work_l?
    user_activities.include? 'certificate_l:work'
  end

  def work_m?
    user_activities.include? 'certificate_m:work'
  end

  def work_r?
    user_activities.include? 'certificate_r:work'
  end
 
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end