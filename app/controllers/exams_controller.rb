class ExamsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :select2_index, :generating_certificates]

  before_action :set_exam, only: [:show, :edit, :update, :destroy, :examination_cards_to_pdf, :examination_protocol_to_pdf, :certificates_to_pdf, :envelopes_to_pdf]

  # GET /exams
  # GET /exams.json
  def index
    case params[:category_service]
      when 'l'
        authorize :exam, :index_l?
      when 'm'
        authorize :exam, :index_m?
      when 'r'
        authorize :exam, :index_r?
    end    
    #dane pobierane z datatables_index
#    respond_to do |format|
#      format.html { render :index, locals: { category_service: params[:category_service]} }
#    end    
  end

  # POST /exams
  def datatables_index
    respond_to do |format|
      #format.json{ render json: ExamDatatable.new(view_context, {category_scope: params[:category] }) }
      format.json{ render json: ExamDatatable.new(view_context) }
    end
  end

  def select2_index
    params[:q] = params[:q]
    @exams = Exam.order(:number).finder_exam(params[:q], (params[:category_service]).upcase)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          exams: @exams_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
          total_count: @exams.count 
        } 
      }
    end
  end

  def examination_cards_to_pdf
    case params[:category_service]
      when 'l'
        authorize :examination, :print_l?
      when 'm'
        authorize :examination, :print_m?
      when 'r'
        authorize :examination, :print_r?
    end    

    @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("customers.name, customers.given_names").all

    if @examinations_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      respond_to do |format|
        format.pdf do
          case params[:category_service]
            when 'l'
              pdf = PdfExaminationCardsL.new(@examinations_all, @exam, view_context)
            when 'm'
              pdf = PdfExaminationCardsM.new(@examinations_all, @exam, view_context)
            when 'r'
              pdf = PdfExaminationCardsR.new(@examinations_all, @exam, view_context)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: "Examination_Cards_#{params[:category_service]}_#{@exam.number}.pdf",
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'examination_cards', filename: "Examination_Cards_#{params[:category_service]}_#{@exam.number}.pdf"}.to_json)
    end 
  end

  def examination_protocol_to_pdf
    case params[:category_service]
      when 'l'
        authorize :examination, :print_l?
      when 'm'
        authorize :examination, :print_m?
      when 'r'
        authorize :examination, :print_r?
    end    

    @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("customers.name, customers.given_names").all

    if @examinations_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      respond_to do |format|
        format.pdf do
          case params[:category_service]
            when 'l'
              pdf = PdfExaminationProtocolL.new(@examinations_all, @exam, view_context)
            when 'm'
              pdf = PdfExaminationProtocolM.new(@examinations_all, @exam, view_context)
            when 'r'
              pdf = PdfExaminationProtocolR.new(@examinations_all, @exam, view_context)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: "Examination_Protocol_#{params[:category_service]}_#{@exam.number}.pdf",
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'examination_protocol', filename: "Examination_Protocol_#{params[:category_service]}_#{@exam.number}.pdf"}.to_json)

    end 
  end

  def certificates_to_pdf
    case params[:category_service]
      when 'l'
        authorize :certificate, :print_l?
      when 'm'
        authorize :certificate, :print_m?
      when 'r'
        authorize :certificate, :print_r?
    end    

    if params[:prnscope].present? && params[:prnscope] != "0" # Wszystkie 
      @certificates_all = Certificate.joins(:customer).references(:customer).where(exam_id: params[:id], division_id: params[:prnscope]).order("customers.name, customers.given_names").all
    else 
      @certificates_all = Certificate.joins(:customer).references(:customer).where(exam_id: params[:id]).order("customers.name, customers.given_names").all
    end 

    if @certificates_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      documentname = "Certificates_#{params[:category_service]}_#{@exam.fullname}.pdf"
      author = "#{current_user.name} (#{current_user.email})"

      respond_to do |format|
        format.pdf do
          case params[:category_service]
            when 'l'
              pdf = PdfCertificatesL.new(@certificates_all, view_context, author, documentname)
            when 'm'
              pdf = PdfCertificatesM.new(@certificates_all, view_context, author, documentname)
            when 'r'
              pdf = PdfCertificatesR.new(@certificates_all, view_context, author, documentname)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: documentname,
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'certificates', filename: "#{documentname}"}.to_json)
    end 
  end

  def envelopes_to_pdf
    authorize :customer, :show?
    @customers_all = @exam.certificate_customers.order(:name, :given_names)

    if @customers_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      documentname = "Envelopes_for_certificates_in_exam_#{@exam.number}.pdf"

      respond_to do |format|
        format.pdf do
          pdf = PdfEnvelopes.new(@customers_all, view_context)
          send_data pdf.render,
          filename: documentname,
          type: "application/pdf",
          disposition: "inline"   
        end
      end
#      @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :to_pdf, user: current_user, 
#                        parameters: {pdf_type: 'envelope', filename: "#{documentname}"}.to_json)

    end 
  end

  # GET /exams/1
  # GET /exams/1.json
  def show
    case params[:category_service]
      when 'l'
        authorize @exam, :show_l?
      when 'm'
        authorize @exam, :show_m?
      when 'r'
        authorize @exam, :show_r?
    end    

    respond_to do |format|
      format.json
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
    # przepych
    # @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :show, user: current_user, parameters: {})
  end

  # GET /exams/new
  def new
    @exam = Exam.new
    @exam.category = (params[:category_service]).upcase
    #@exam.examiners.new
    #@exam.examiners.new
    (1..8).each { @exam.examiners.build }
    case params[:category_service]
      when 'l'
        authorize @exam, :new_l?
      when 'm'
        authorize @exam, :new_m?
      when 'r'
        authorize @exam, :new_r?
    end    
  end

  # GET /exams/1/edit
  def edit
    count = @exam.examiners.size
    add_empty = 8 - count
    add_empty += 1 if count >= 8
    #@exam.examiners.build
    (1..add_empty).each { @exam.examiners.build }
    case params[:category_service]
      when 'l'
        authorize @exam, :edit_l?
      when 'm'
        authorize @exam, :edit_m?
      when 'r'
        authorize @exam, :edit_r?
    end    
  end

  # POST /exams
  # POST /exams.json
  def create
    @exam = Exam.new(exam_params)
    @exam.category = (params[:category_service]).upcase
    @exam.user = current_user
    case params[:category_service]
      when 'l'
        authorize @exam, :create_l?
      when 'm'
        authorize @exam, :create_m?
      when 'r'
        authorize @exam, :create_r?
    end    

    respond_to do |format|
      if @exam.save
        @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :create, user: current_user, 
          parameters: @exam.to_json(except: [:user_id, :code], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))

        format.html { redirect_to exam_path(@exam, category_service: params[:category_service]), notice: t('activerecord.messages.successfull.created', data: @exam.number) }
        format.json { render :show, status: :created, location: @exam }
      else
        format.html { render :new }
        format.json { render json: @exam.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exams/1
  # PATCH/PUT /exams/1.json
  def update
    @exam.user = current_user
    case params[:category_service]
      when 'l'
        authorize @exam, :update_l?
      when 'm'
        authorize @exam, :update_m?
      when 'r'
        authorize @exam, :update_r?
    end    

    respond_to do |format|
      if @exam.update(exam_params)
        @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :update, user: current_user, 
          parameters: @exam.to_json(except: [:user_id, :code], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))

        format.html { redirect_to exam_path(@exam, category_service: params[:category_service]), notice: t('activerecord.messages.successfull.updated', data: @exam.number) }
        format.json { render :show, status: :ok, location: @exam }
      else
        format.html { render :edit }
        format.json { render json: @exam.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exams/1
  # DELETE /exams/1.json
  def destroy
    case params[:category_service]
      when 'l'
        authorize @exam, :destroy_l?
      when 'm'
        authorize @exam, :destroy_m?
      when 'r'
        authorize @exam, :destroy_r?
    end    

    if @exam.destroy
      Work.create!(trackable: @exam, action: :destroy, user: current_user, 
          parameters: @exam.to_json(except: [:user_id, :code], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))
      redirect_to exams_url, notice: t('activerecord.messages.successfull.destroyed', data: @exam.number)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @exam.number)
      render :show
    end      
  end

  def generating_certificates 
    @exam = Exam.find(params[:id]) 

    # wywołanie funkcji z JS, by nie odświeżać całej strony
    @exam.generate_all_certificates(current_user.id)
    #flash.now[:notice] = t('activerecord.messages.successfull.numbering', data: @insurance.number)
    #flash[:notice] = t('activerecord.messages.successfull.numbering', data: @insurance.number)
    render :nothing => true and return
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exam
      @exam = Exam.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exam_params
      params.require(:exam).permit(:number, :date_exam, :place_exam, :chairman, :secretary, :category, :note, :user_id, examiners_attributes: [:id, :name, :_destroy])
    end
end
