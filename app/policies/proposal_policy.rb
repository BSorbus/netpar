class ProposalPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def index_l?
    user_activities.include? 'proposal_l:index'
  end

  def index_m?
    user_activities.include? 'proposal_m:index'
  end

  def index_r?
    user_activities.include? 'proposal_r:index'
  end

  def index?
    false
    #user_activities.include? 'proposal:index'
  end

  def show_l?
    user_activities.include? 'proposal_l:show'
  end

  def show_m?
    user_activities.include? 'proposal_m:show'
  end

  def show_r?
    user_activities.include? 'proposal_r:show'
  end

  def show?
    false
    #user_activities.include? 'proposal:show'
  end

  def new_l?
    user_activities.include? 'proposal_l:create'
  end

  def new_m?
    user_activities.include? 'proposal_m:create'
  end

  def new_r?
    user_activities.include? 'proposal_r:create'
  end

  def new?
    false
    #user_activities.include? 'proposal:create'
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
    user_activities.include? 'proposal_l:update'
  end

  def edit_m?
    (@model.can_edit?) && (user_activities.include? 'proposal_m:update')
  end

  def edit_r?
    (@model.can_edit?) && (user_activities.include? 'proposal_r:update')
  end

  def edit_approved_m?
    (@model.can_edit_approved?) && (user_activities.include? 'proposal_m:update')
  end

  def edit_approved_r?
    (@model.can_edit_approved?) && (user_activities.include? 'proposal_r:update')
  end

  def edit_not_approved_m?
    (@model.can_edit_not_approved?) && (user_activities.include? 'proposal_m:update')
  end

  def edit_not_approved_r?
    (@model.can_edit_not_approved?) && (user_activities.include? 'proposal_r:update')
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

  def update_approved_m?
    edit_approved_m?
  end

  def update_approved_r?
    edit_approved_r?
  end

  def update_not_approved_m?
    edit_not_approved_m?
  end

  def update_not_approved_r?
    edit_not_approved_r?
  end

  def update?
    edit?
  end

  def destroy_l?
    user_activities.include? 'proposal_l:delete'
  end
 
  def destroy_m?
    user_activities.include? 'proposal_m:delete'
  end
 
  def destroy_r?
    user_activities.include? 'proposal_r:delete'
  end
 
  def destroy?
    false
  end
 
  def print_l?
    user_activities.include? 'proposal_l:print'
  end

  def print_m?
    user_activities.include? 'proposal_m:print'
  end

  def print_r?
    user_activities.include? 'proposal_r:print'
  end
 
  def work_l?
    user_activities.include? 'proposal_l:work'
  end

  def work_m?
    user_activities.include? 'proposal_m:work'
  end

  def work_r?
    user_activities.include? 'proposal_r:work'
  end
 
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end