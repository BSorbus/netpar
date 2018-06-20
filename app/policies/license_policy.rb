class LicensePolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
  	#raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @model = model
  end

  def show?
    user_activities.include? 'license:show'
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end