class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_user, only: [:show, :edit, :update, :destroy]

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
        format.html { redirect_to @user, notice: t('activerecord.messages.successfull.updated', data: @user.name) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize user, :destroy?
    
    user.destroy
    redirect_to users_path, :notice => "User deleted."
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
