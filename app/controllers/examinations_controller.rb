class ExaminationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index_exam]

  before_action :set_examination, only: [:show, :edit, :update, :destroy]

  # GET /examinations
  # GET /examinations.json
  def index
    case params[:category_service]
      when 'l'
        authorize :examination, :index_l?
      when 'm'
        authorize :examination, :index_m?
      when 'r'
        authorize :examination, :index_r?
    end    
    # dane pobierane z datatables_index
  end

  def datatables_index_exam
    respond_to do |format|
      format.json{ render json: ExamExaminationsDatatable.new(view_context, { only_for_current_exam_id: params[:exam_id] }) }
    end
  end

  # GET /examinations/1
  # GET /examinations/1.json
  def show
    case params[:category_service]
      when 'l'
        authorize @examination, :show_l?
      when 'm'
        authorize @examination, :show_m?
      when 'r'
        authorize @examination, :show_r?
    end    

    respond_to do |format|
      format.json
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
  end

  # GET /examinations/new
  def new
    @examination = Examination.new
    @examination.category = (params[:category_service]).upcase
    

    @exam = load_exam
    @examination.exam = @exam

    @customer = load_customer
    @examination.customer = @customer

    case params[:category_service]
      when 'l'
        authorize @examination, :new_l?
      when 'm'
        authorize @examination, :new_m?
      when 'r'
        authorize @examination, :new_r?
    end    
    respond_to do |format|
      format.json
      format.html { render :new, locals: { back_url: params[:back_url]} }
    end
  end

  # GET /examinations/1/edit
  def edit
    case params[:category_service]
      when 'l'
        authorize @examination, :edit_l?
      when 'm'
        authorize @examination, :edit_m?
      when 'r'
        authorize @examination, :edit_r?
    end    
    respond_to do |format|
      format.json
      format.html { render :edit, locals: { back_url: params[:back_url]} }
    end
  end

  # POST /examinations
  # POST /examinations.json
  def create
    @examination = Examination.new(examination_params)
    @examination.category = (params[:category_service]).upcase
    case params[:category_service]
      when 'l'
        authorize @examination, :create_l?
      when 'm'
        authorize @examination, :create_m?
      when 'r'
        authorize @examination, :create_r?
    end    

    respond_to do |format|
      if @examination.save
        format.html { redirect_to examination_path(@examination, category_service: params[:category_service], back_url: params[:back_url]), notice: t('activerecord.messages.successfull.created', data: @examination.id) }
        format.json { render :show, status: :created, location: @examination }
      else
        format.html { render :new, locals: { back_url: params[:back_url]} }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /examinations/1
  # PATCH/PUT /examinations/1.json
 def update
    case params[:category_service]
      when 'l'
        authorize @examination, :update_l?
      when 'm'
        authorize @examination, :update_m?
      when 'r'
        authorize @examination, :update_r?
    end    
    respond_to do |format|
      if @examination.update(examination_params)
        format.html { redirect_to examination_path(@examination, category_service: params[:category_service], back_url: params[:back_url]), notice: t('activerecord.messages.successfull.updated', data: @examination.fullname) }
        format.json { render :show, status: :ok, location: @examination }
      else
        format.html { render :edit, locals: { back_url: params[:back_url]} }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /examinations/1
  # DELETE /examinations/1.json
  def destroy
    case params[:category_service]
      when 'l'
        authorize @examination, :destroy_l?
      when 'm'
        authorize @examination, :destroy_m?
      when 'r'
        authorize @examination, :destroy_r?
    end    

    if @examination.destroy
      redirect_to params[:back_url], notice: t('activerecord.messages.successfull.destroyed', data: @examination.fullname)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @examination.fullname)
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.find(params[:id])
    end

    def load_exam
      Exam.find(params[:exam_id]) if (params[:exam_id]).present?
    end

    def load_customer
      Customer.find(params[:customer_id]) if (params[:customer_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def examination_params
      params.require(:examination).permit(:examination_category, :division_id, :examination_resoult, :exam_id, :customer_id, :certificate_id, :note, :category, :exam_id, :user_id)
    end
end
