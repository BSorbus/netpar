class RolesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index]

  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = Role.order(:name).all
    authorize :role, :index?
  end

  def show
    authorize @role, :show?
    #authorize :role, :show?
  end

  def new
    @role = Role.new
    authorize :role, :new?
  end

  # GET /roles/1/edit
  def edit
    authorize @role, :edit?
    #authorize :role, :edit?
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Department.new(role_params)
    authorize @role, :create?

    respond_to do |format|
      if @role.save
        format.html { redirect_to @role, notice: t('activerecord.messages.successfull.created', data: @role.name) }
        format.json { render :show, status: :created, location: @role }
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @role, :update?
    
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to @role, notice: t('activerecord.messages.successfull.updated', data: @role.name) }
        format.json { render :show, status: :ok, location: @role }
      else
        format.html { render :edit }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @role, :destroy?

    if @role.destroy
      redirect_to roles_url, notice: t('activerecord.messages.successfull.destroyed', data: @role.name)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @role.name)
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :activities)
    end

end
