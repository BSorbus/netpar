class Roles::UsersController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized

  def create
    @role = Role.find(params[:role_id])
    @user = User.find(params[:id])
    authorize @role, :add_remove_role_user?

    @role.users << @user
    redirect_to :back, notice: t('activerecord.messages.successfull.add_role', parent: @user.name, child: @role.name)
  end

  def destroy
    @role = Role.find(params[:role_id])
    @user = User.find(params[:id])
    authorize @role, :add_remove_role_user?

    @role.users.delete(@user)
    redirect_to :back, notice: t('activerecord.messages.successfull.remove_role', parent: @user.name, child: @role.name)
  end

end
