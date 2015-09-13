class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_user, only: [:show, :edit, :update, :destroy, :lock, :unlock]


#  def index
#    @users = User.order(:name).all
#    authorize :user, :index?
#  end

  def index
    authorize :user, :index?
    respond_to do |format|
      format.html
    end   
  end

  # POST /companies
  def datatables_index
    respond_to do |format|
      format.json{ render json: UserDatatable.new(view_context) }
    end
  end

  def show
    authorize @user, :show?
    # przepych
    # Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :show, user: current_user, parameters: {})
  end

  # GET /departments/1/edit
  def edit
    authorize @user, :edit?
    #authorize :department, :edit?
  end

#  def update
#    authorize @user, :update?
#
#    if @user.update_attributes(secure_params)
#      redirect_to users_path, :notice => "User updated."
#    else
#      redirect_to users_path, :alert => "Unable to update user."
#    end
#  end

  def update
    authorize @user, :update?
    
    respond_to do |format|
      if @user.update_attributes(secure_params)

        Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :update, user: current_user, parameters: @user.previous_changes.to_hash)

        format.html { redirect_to @user, notice: t('activerecord.messages.successfull.updated', data: @user.name) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user, :destroy?
    
    u = @user
    cu = current_user
    if @user.destroy
      Work.create!(trackable_id: u.id, trackable_type: 'User', action: :destroy, user: cu, parameters: {name: u.name, email: u.email})
      redirect_to users_url, notice: t('activerecord.messages.successfull.destroyed', data: u.fullname_and_id)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: u.fullname_and_id)
      render :show
    end      
  end

  def lock
    authorize @user, :update?

    @user.soft_delete
    if @user.save
      Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :account_lock, user: current_user, 
        parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: @user.id, name: @user.name, email: @user.email})
      redirect_to @user, notice: t('activerecord.messages.successfull.locking_user', data: @user.fullname_and_id)
    else 
      flash.now[:error] = t('activerecord.messages.error.locking_user', data: @user.fullname_and_id)
      render :show 
    end         
  end

  def unlock
    authorize @user, :update?

    @user.deleted_at = nil
    if @user.save
      Work.create!(trackable: @user, trackable_url: "#{user_path(@user)}", action: :account_unlock, user: current_user, 
        parameters: {remote_ip: request.remote_ip, fullpath: request.fullpath, id: @user.id, name: @user.name, email: @user.email})
      redirect_to @user, notice: t('activerecord.messages.successfull.unlocking_user', data: @user.fullname_and_id)
    else 
      flash.now[:error] = t('activerecord.messages.error.unlocking_user', data: @user.fullname_and_id)
      render :show 
    end         
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def secure_params
      params.require(:user).permit(:name, :department_id)
    end

end
