class RolesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index_user]

  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = Role.order(:name).all
    authorize :role, :index?
  end

  def datatables_index_user
    respond_to do |format|
      format.json{ render json: UserRolesDatatable.new(view_context, { only_for_current_user_id: params[:user_id] }) }
    end
  end

  def show
    authorize @role, :show?
    # przepych
    # @role.works.create!(trackable_url: "#{role_path(@role)}", action: :show, user: current_user, parameters: {})
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
    @role = Role.new(role_params)
    #@role.user = current_user
    authorize @role, :create?

    respond_to do |format|
      if @role.save
        @role.works.create!(trackable_url: "#{role_path(@role)}", action: :create, user: current_user, 
          parameters: @role.attributes.to_json)

        flash_message :success, t('activerecord.messages.successfull.created', data: @role.name)
        format.html { redirect_to @role }
        format.json { render :show, status: :created, location: @role }
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    #@role.user = current_user
    authorize @role, :update?
    
    respond_to do |format|
      if @role.update(role_params)
        @role.works.create!(trackable_url: "#{role_path(@role)}", action: :update, user: current_user, 
          parameters: @role.previous_changes.to_json)


        flash_message :success, t('activerecord.messages.successfull.updated', data: @role.name)
        format.html { redirect_to @role }
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
      Work.create!(trackable: @role, action: :destroy, user: current_user, 
        parameters: @role.attributes.to_json)

      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @role.name)
      redirect_to roles_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @role.name)
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
