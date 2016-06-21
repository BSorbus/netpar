class Roles::UsersController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized

  def create
    @role = Role.find(params[:role_id])
    @user = User.find(params[:id])
    authorize @role, :add_remove_role_user?

    @role.users << @user

    Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :add_role, user: current_user, parameters: {role: @role.fullname_and_id, user: @user.fullname_and_id})

    flash_message :success, t('activerecord.messages.successfull.add_role', parent: @user.name, child: @role.name)
    redirect_to :back
  end

  def destroy
    @role = Role.find(params[:role_id])
    @user = User.find(params[:id])
    authorize @role, :add_remove_role_user?

    @role.users.delete(@user)

    Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :remove_role, user: current_user, parameters: {role: @role.fullname_and_id, user: @user.fullname_and_id})

    flash_message :success, t('activerecord.messages.successfull.remove_role', parent: @user.name, child: @role.name)
    redirect_to :back
  end

end
