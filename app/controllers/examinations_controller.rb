require 'esodes'

class ExaminationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index_exam]

  before_action :set_examination, only: [:show, :edit, :update, :destroy]

  # GET /examinations
  # GET /examinations.json
  def index
    examination_authorize(:examination, "index", params[:category_service])
    # dane pobierane z datatables_index
  end

  def datatables_index_exam
    respond_to do |format|
      format.json{ render json: ExamExaminationsDatatable.new(view_context, { only_for_current_exam_id: params[:exam_id] }) }
    end
  end

  def examination_card_to_pdf
    examination_authorize(:examination, "print", params[:category_service])

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
                        parameters: {pdf_type: 'examination_card', filename: "Examination_Card_#{params[:category_service]}_#{@examination.first.exam.number}_#{@examination.first.customer.fullname}.pdf"}.to_json)

    end 
  end

  # GET /examinations/1
  # GET /examinations/1.json
  def show
    examination_authorize(:examination, "show", params[:category_service])

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
    @examination.esod_category = (params[:esod_category]) if params[:esod_category].present?

    examination_authorize(@examination, "new", params[:category_service])

    @esod_matter = load_esod_matter
    if @esod_matter.present?
      @examination.esod_matter = @esod_matter
      @examination.esod_category = @esod_matter.identyfikator_kategorii_sprawy
    end
    
    @exam = load_exam
    @examination.exam = @exam

    @customer = load_customer
    @examination.customer = @customer

    respond_to do |format|
      format.json
      format.html { render :new, locals: { back_url: params[:back_url]} }
    end
  end

  # GET /examinations/1/edit
  def edit
#    count = @examination.grades.size
#    (1..count).each { @examination.grades.build }

    examination_authorize(@examination, "edit", params[:category_service])

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

    examination_authorize(@examination, "create", params[:category_service])

    respond_to do |format|
      if @examination.save
        @examination.division.subjects.where("'?' = ANY (esod_categories)", @examination.esod_category).order(:item).each do |subject|
          if Esodes::ORDINARY_EXAMINATIONS.include?(@examination.esod_category) #egzamin zwykły/zwykły PW 
            @examination.grades.create!(user: @examination.user, subject: subject)
          else #jesli to egzamin poprawkowy/odnowienie z egzaminem, poprawkowy
            # poszukaj ocen z oceną negatywną
            customer_last_examination = Examination.where(customer: @examination.customer, division: @examination.division, examination_result: 'N').last # Negatywny z prawem do poprawki
            if customer_last_examination.present?
              @examination.grades.create!(user: @examination.user, subject: subject) if customer_last_examination.grades.where(grade_result: 'N', subject: subject).any?
            else
              @examination.grades.create!(user: @examination.user, subject: subject)
            end
          end
        end

        @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :create, user: current_user, 
          parameters: @examination.attributes.to_json)

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

    examination_authorize(@examination, "update", params[:category_service])

    respond_to do |format|
      if @examination.update(examination_params)

        h_grades = {}
        @examination.grades.order(:id).each do |grade|
          h_grades["#{grade.subject.name}"] = grade.grade_result
        end
 
        @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :update, user: current_user, 
          parameters: {examination: @examination.previous_changes, grades: h_grades}.to_json)

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
    examination_authorize(@examination, "destroy", params[:category_service])

    exam = @examination.exam
    if @examination.destroy
      Work.create!(trackable: @examination, action: :destroy, user: current_user, parameters: @examination.attributes.to_json)
      redirect_to (params[:back_url]).present? ? params[:back_url] : exam_path(exam, category_service: params[:category_service]), notice: t('activerecord.messages.successfull.destroyed', data: @examination.fullname)
    else 
      flash.now[:alert] = t('activerecord.messages.error.destroyed', data: @examination.fullname)
      render :show
    end      
  end

  private
    def examination_authorize(model_class, action, category)
      unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work'].include?(action)
         raise "Ruby injection"
      end
      unless ['l', 'm', 'r'].include?(category)
         raise "Ruby injection"
      end
      authorize model_class,"#{action}_#{category}?"      
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.find(params[:id])
    end

    def load_esod_matter
      Esod::Matter.find(params[:esod_matter_id]) if (params[:esod_matter_id]).present?
    end

    def load_exam
      Exam.find(params[:exam_id]) if (params[:exam_id]).present?
    end

    def load_customer
      Customer.find(params[:customer_id]) if (params[:customer_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def examination_params
      params.require(:examination).permit(:esod_category, :division_id, :exam_id, :customer_id, :examination_result, :certificate_id, :note, :category, :exam_id, :user_id, :esod_matter_id, grades_attributes: [:id, :grade_result])
    end
end
