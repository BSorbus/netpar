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

  def examination_card_to_pdf
    case params[:category_service]
      when 'l'
        authorize :examination, :print_l?
      when 'm'
        authorize :examination, :print_m?
      when 'r'
        authorize :examination, :print_r?
    end    

    # where(id: param[:id]) czyli pojedynczy rekord @examinations_all -> @examination ale jako lista 
    @examination = Examination.joins(:customer).references(:customer).where(id: params[:id]).all

    if @examination.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      respond_to do |format|
        format.pdf do
          case params[:category_service]
            when 'l'
              pdf = PdfExaminationCardsL.new(@examination, @examination.first.exam, view_context)
            when 'm'
              pdf = PdfExaminationCardsM.new(@examination, @examination.first.exam, view_context)
            when 'r'
              pdf = PdfExaminationCardsR.new(@examination, @examination.first.exam, view_context)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: "Examination_Card_#{params[:category_service]}_#{@examination.first.exam.number}_#{@examination.first.customer.fullname}.pdf",
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @examination.first.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'examination_card', filename: "Examination_Card_#{params[:category_service]}_#{@examination.first.exam.number}_#{@examination.first.customer.fullname}.pdf"})

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
    # przepych
    # @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :show, user: current_user, parameters: {})
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
#    count = @examination.grades.size
#    (1..count).each { @examination.grades.build }

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
    @examination.user = current_user
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
        @examination.division.subjects.order(:item).each do |subject|
          @examination.grades.create!(user: @examination.user, subject: subject)
        end

        @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :create, user: current_user, parameters: @examination.attributes.to_hash)

        format.html { redirect_to examination_path(@examination, category_service: params[:category_service], back_url: params[:back_url]), notice: t('activerecord.messages.successfull.created', data: @examination.fullname) }
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
    @examination.user = current_user
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

        h_grades = {}
        @examination.grades.order(:id).each do |grade|
          h_grades["#{grade.subject.name}"] = grade.grade_result
        end
 
        @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :update, user: current_user, 
          parameters: {examination: @examination.previous_changes.to_hash, grades: h_grades})

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

    exam = @examination.exam
    if @examination.destroy
      Work.create!(trackable: @examination, action: :destroy, user: current_user)
      redirect_to (params[:back_url]).present? ? params[:back_url] : exam_path(exam, category_service: params[:category_service]), notice: t('activerecord.messages.successfull.destroyed', data: @examination.fullname)
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
      params.require(:examination).permit(:examination_category, :division_id, :examination_result, :exam_id, :customer_id, :certificate_id, :note, :category, :exam_id, :user_id, grades_attributes: [:id, :grade_result])
    end
end
