class DepartmentsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index]

  before_action :set_department, only: [:show, :edit, :update, :destroy]

  # GET /departments
  # GET /departments.json
  def index
    @departments = Department.order(:id).all
    authorize :department, :index?
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    authorize @department, :show?
    #authorize :role, :show?  
  end

  # GET /departments/new
  def new
    @department = Department.new
    authorize :department, :new?
  end

  # GET /departments/1/edit
  def edit
    authorize @department, :edit?
    #authorize :department, :edit?
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)
    authorize @department, :create?

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: t('activerecord.messages.successfull.created', data: @department.short) }
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    authorize @department, :update?
    
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: t('activerecord.messages.successfull.updated', data: @department.short) }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    authorize @department, :destroy?

    if @department.destroy
      redirect_to departments_url, notice: t('activerecord.messages.successfull.destroyed', data: @department.short)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @department.short)
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:short, :name, :address_city, :address_street, :address_house, :address_number, :phone, :fax, :email, :director, :code)
    end
end
