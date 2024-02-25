require 'esodes'

class ExamsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :select2_index, :certificates_generation]

  before_action :set_exam, only: [:show, :edit, :update, :destroy, :force_destroy, :download_testportal_pdfs, :examination_cards_to_pdf, :examination_protocol_to_pdf, :certificates_to_pdf, :envelopes_to_pdf, :exam_report_to_pdf, :committee_docx, :esod_matter_link]
  before_action :set_esod_user_id, only: [:show]

  # GET /exams
  # GET /exams.json
  def index
    exam_authorize(:exam, "index", params[:category_service])
    #dane pobierane z datatables_index
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
        render json: @exams_on_page, each_serializer: ExamSerializer, meta: {total_count: @exams.count}
      } 
#      format.json { 
#        render json: { 
#          exams: @exams_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
#          total_count: @exams.count 
#        } 
#      }
    end
  end

  def examination_cards_to_pdf
    exam_authorize(:examination, "print", params[:category_service])

    case params[:prnorder]
    when 'customers.name, customers.given_names'
      @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("customers.name, customers.given_names").all
    else # 'id'
      @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("examinations.id").all
    end

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
    exam_authorize(:exam, "print", params[:category_service])

    case params[:prnorder]
    when 'customers.name, customers.given_names'
      @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("customers.name, customers.given_names").all
    else 
      @examinations_all = Examination.joins(:customer).references(:customer).where(exam_id: params[:id]).order("examinations.id").all
    end

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
    exam_authorize(:certificate, "print", params[:category_service])

    if params[:prnscope].present? && params[:prnscope] != "0" # Wszystkie 
      @certificates_all = Certificate.joins(:customer).references(:customer).where(exam_id: params[:id], division_id: params[:prnscope]).all
    else 
      @certificates_all = Certificate.joins(:customer).references(:customer).where(exam_id: params[:id]).all
    end 


    if params[:prnorder].present? && ['id', 'customers.name, customers.given_names'].include?(params[:prnorder]) # Wszystkie
      my_order = params[:prnorder].gsub("id", "certificates.id") 
      @certificates_all = @certificates_all.order(my_order)
    else
      @certificates_all = @certificates_all.order(:id)
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
    #@customers_all = @exam.certificate_customers.order(:name, :given_names)

    case params[:prnorder]
    when 'id'
      @customers_all = @exam.certificate_customers.order("certificates.updated_at")
    else 
      @customers_all = @exam.certificate_customers.order("customers.name, customers.given_names")
      #@customers_all = @exam.certificate_customers.order(:name, :given_names)      
    end

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

  # GET /:category_service/statistic_filter
  def statistic_filter
    exam_authorize(:exam, "print", params[:category_service])

    respond_to do |format|
      format.html { render :statistic_filter }
    end
  end

  # GET /:category_service/statistic_filter
  def statistic_to_pdf
    exam_authorize(:exam, "print", params[:category_service])

    if (params[:date_start]).blank? || (params[:date_end]).blank?
      flash_message :error, 'Musisz zdefiniować parametry "Data od" i "Data do"'
      render 'statistic_filter.html.erb'
    else
      respond_to do |format|
        format.pdf do
          pdf = PdfExamStatistic.new(params[:category_service], params[:date_start], params[:date_end], view_context)
          send_data pdf.render,
          filename: "Statistic_#{params[:category_service]}_#{params[:date_start]}_#{params[:date_end]}.pdf",
          type: "application/pdf",
          disposition: "inline"
        end
      end
    end
  end

  # GET /:category_service/statistic_filter
  def statistic2_to_pdf
    exam_authorize(:exam, "print", params[:category_service])
    theme = params[:theme] == 'dokument' ? 'dokument' : 'sesja'
    if (params[:date_start2]).blank? || (params[:date_end2]).blank? || (params[:max_day]).blank? || (params[:theme]).blank?
      flash_message :error, 'Musisz zdefiniować parametry "Data od", "Data do" oraz "Ilość dni - wskaźnik" i "analizuj względem"'
      render 'statistic_filter.html.erb'
    else
      respond_to do |format|
        format.pdf do
          pdf = PdfExamStatistic2.new(params[:category_service], params[:date_start2], params[:date_end2], params[:max_day], "#{theme}", view_context)
          send_data pdf.render,
          filename: "Statistic2_#{params[:category_service]}_#{params[:date_start2]}_#{params[:date_end2]}_#{params[:max_day]}_dni_#{theme}.pdf",
          type: "application/pdf",
          disposition: "inline"
        end
      end
    end
  end

  def committee_docx
    exam_authorize(@exam, "edit", params[:category_service])

    respond_to do |format|
      format.docx do
        # Initialize DocxReplace with your template
        doc = DocxReplace::Doc.new("#{Rails.root}/lib/docx_templates/exam_#{params[:category_service]}_committee.docx", "#{Rails.root}/tmp")

        # Replace some variables. $var$ convention is used here, but not required.
        #doc.replace("$departmentcity$", "Bydgoszczu")
        doc.replace("$departmentcity$", "#{@current_user.department.address_city}, dn. #{DateTime.now.to_date.strftime('%d.%m.%Y')} r.")
        doc.replace("$esodznak$", "#{@exam.esod_matter.znak}.1")
        doc.replace("$examnumber$", "#{@exam.number}")
        doc.replace("$placeexam$", "#{@exam.place_exam}")
        doc.replace("$dateexam$", "#{@exam.date_exam.strftime('%d.%m.%Y')} r.")
        doc.replace("$examchairman$", "#{@exam.chairman}")
        doc.replace("$examsecretary$", "#{@exam.secretary}")
        @exam.examiners.order(:name).each_with_index do |examiner, n|
          doc.replace("$examiner#{n}$", "#{n + 3}. Członek:")
          doc.replace("$examiner#{n}name$", "#{examiner.name}")
        end
        n_count = @exam.examiners.size
        (10 - n_count).times do |n|
          doc.replace("$examiner#{n_count + n}$", "")
          doc.replace("$examiner#{n_count + n}name$", "")
        end

        doc.replace("$username$", "#{@current_user.name}")
        doc.replace("$netparstopka$", "wygenerowano z programu https://#{Rails.application.secrets.domain_name}  © UKE-BI-WUSA (BJ) 2015")

        # Write the document back to a temporary file
        tmp_file = Tempfile.new('word_tempate', "#{Rails.root}/tmp")
        doc.commit(tmp_file.path)

        # Respond to the request by sending the temp file
        send_file tmp_file.path, filename: "exam_#{params[:category_service]}_comittee_#{@exam.fullname}.docx", disposition: 'attachment'
      end
    end
  end

  # GET /exams/1
  # GET /exams/1.json
  def show
    exam_authorize(:exam, "show", params[:category_service])

    set_initial_esod_data

    respond_to do |format|
      # for jBuilder
      #format.json 
      # if using active_model_serializer
      format.json { render json: @exam, root: false }
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
    # przepych
    # @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :show, user: current_user, parameters: {})
  end

  # GET /exams/new
  def new
    @exam = Exam.new 
    @exam.category = (params[:category_service]).upcase
    params[:category_service] == 'l' ? @exam.esod_category = Esodes::SESJA_BEZ_EGZAMINOW : @exam.esod_category = Esodes::SESJA

    exam_authorize(@exam, "new", params[:category_service])
 
    @esod_matter = load_esod_matter
    if @esod_matter.present?
      @exam.esod_category = @esod_matter.identyfikator_kategorii_sprawy
      @exam.number = @esod_matter.exam_number
      @exam.date_exam = @esod_matter.termin_realizacji - Esodes::limit_time_add_to_exam(@exam.category)
      @exam.place_exam = @esod_matter.exam_place
    end
  end

  # GET /exams/1/edit
  def edit
    exam_authorize(@exam, "edit", params[:category_service])
  end

  # POST /exams
  # POST /exams.json
  def create
    @exam = Exam.new(exam_params)
    @exam.category = (params[:category_service]).upcase
    @exam.user = current_user

    exam_authorize(@exam, "create", params[:category_service])

    respond_to do |format|
      if @exam.save
        @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :create, user: current_user, 
          parameters: @exam.to_json(except: [:user_id], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))

        flash_message :success, t('activerecord.messages.successfull.created', data: @exam.number)
        format.html { redirect_to exam_path(@exam, category_service: params[:category_service]) }
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

    exam_authorize(@exam, "update", params[:category_service])

    respond_to do |format|
      if @exam.update(exam_params)
        @exam.works.create!(trackable_url: "#{exam_path(@exam, category_service: params[:category_service])}", action: :update, user: current_user, 
          parameters: @exam.to_json(except: [:user_id], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))

        flash_message :success, t('activerecord.messages.successfull.updated', data: @exam.number)
        format.html { redirect_to exam_path(@exam, category_service: params[:category_service]) }
        format.json { render :show, status: :ok, location: @exam }
      else
        format.html { render :edit }
        format.json { render json: @exam.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /exams/:id/esod_matter_link
  def esod_matter_link
    exam_authorize(@exam, "update", params[:category_service])
    @esod_matter = Esod::Matter.find_by(id: params[:source_id])
    @esod_matter.exam = @exam

    if @esod_matter.save
      @esod_matter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :esod_matter_link, user: current_user, 
                            parameters: {esod_matter: @esod_matter.fullname, link: @exam.fullname}.to_json)

      flash_message :success, t('activerecord.messages.successfull.esod_matter_link', parent: @exam.number, child: @esod_matter.fullname)
      redirect_to :back 
    else
      flash_message :error, t('activerecord.messages.error.esod_matter_link', parent: @exam.number, child: @esod_matter.fullname)
      redirect_to :back 
    end
  end

  # DELETE /exams/1
  # DELETE /exams/1.json
  def destroy
    exam_authorize(@exam, "destroy", params[:category_service])
    # destroyed_clone = @exam.clone

    if @exam.destroy
      Work.create!(trackable: @exam, action: :destroy, user: current_user, 
          parameters: @exam.to_json(except: [:user_id], 
                                    include: {
                                      # esod_matter: {only: [:znak]}, 
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @exam.number)
      redirect_to exams_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @exam.number)
      set_initial_esod_data
      render :show
      #redirect_to :back
    end      
  end

  def force_destroy
    exam_authorize(@exam, "force_destroy", params[:category_service])
    # destroyed_clone = @exam.clone

    if @exam.force_destroy
      Work.create!(trackable: @exam, action: :destroy, user: current_user, 
          parameters: @exam.to_json(except: [:user_id], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @exam.number)
      redirect_to exams_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @exam.number)
      set_initial_esod_data
      render :show
      #redirect_to :back
    end      
  end

  def download_testportal_pdfs
    exam_authorize(@exam, "update", params[:category_service])

    sum_file_downloaded = 0
    @exam.exams_divisions_subjects.each do |eds|
      sum_file_downloaded += eds.download_results_pdfs_from_testportal_and_save
    end
    if sum_file_downloaded > 0
      Work.create!(trackable: @exam, action: :download_testportal_pdfs, user: current_user, 
          parameters: @exam.to_json(except: [:user_id], 
                                    include: {
                                      user: {only: [:id, :name, :email]},
                                      examiners: {only: [:name]}
                                    }))
      flash_message :success, t('activerecord.messages.successfull.download_testportal_pdfs', data: @exam.number, sum_files: sum_file_downloaded)
    else 
      flash_message :error, t('activerecord.messages.error.download_testportal_pdfs', data: @exam.number)
    end      
    set_initial_esod_data
    render :show
  end


  def certificates_generation 
    @exam = Exam.find(params[:id]) 
    # wywołanie funkcji z JS, by nie odświeżać całej strony
    @exam.generate_all_certificates(current_user.id)
    #flash.now[:notice] = t('activerecord.messages.successfull.numbering', data: @insurance.number)
    #flash[:notice] = t('activerecord.messages.successfull.numbering', data: @insurance.number)
    render :nothing => true and return
  end


  private
    def exam_authorize(model_class, action, category)
      unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'force_destroy', 'print', 'work'].include?(action)
         raise "Ruby injection"
      end
      unless ['l', 'm', 'r'].include?(category)
         raise "Ruby injection"
      end
      authorize model_class,"#{action}_#{category}?"      
    end

    # Use callbacks to share common setup or constraints between actions.
    # For cooperation with ESOD
    def set_esod_user_id
      Esodes::EsodTokenData.new(current_user.id)
    end

    def set_exam
      @exam = Exam.find(params[:id])
    end

    def load_esod_matter
      Esod::Matter.find(params[:esod_matter_id]) if (params[:esod_matter_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def exam_params
    #   params.require(:exam).permit(:esod_category, :number, :date_exam, :place_exam, :info, :chairman, :secretary, :category, :note, :user_id, 
    #     :province_id, :max_examinations, :online, examiners_attributes: [:id, :name, :_destroy], exams_divisions_attributes: [:id, :division_id, :_destroy]).tap do |xx|

    #     aa
    #   end
    # end

    def set_initial_esod_data
    # for matter_add action
    @esod_matter = @exam.esod_matters.new(
      nrid: nil,
      znak: nil,
      znak_sprawy_grupujacej: nil,
      symbol_jrwa: Esodes::esod_matter_service_jrwa(@exam.category).to_s,
      tytul: "#{@exam.number}, #{@exam.place_exam}",
      termin_realizacji: @exam.date_exam + Esodes::limit_time_add_to_exam(@exam.category),
      identyfikator_kategorii_sprawy: @exam.category == 'L' ? Esodes::SESJA_BEZ_EGZAMINOW : Esodes::SESJA,
      identyfikator_stanowiska_referenta: nil,
      czy_otwarta: true,
      initialized_from_esod: nil,
      netpar_user: nil )

    @esod_matter.esod_matter_notes.build

    # for incoming_letter_add action
    @esod_incoming_letter = @exam.esod_matters.last.esod_incoming_letters.new()
#      nrid: nil,
#      numer_ewidencyjny: nil,
#      tytul: "Skład komisji / ??? ...@exam.number",
#      data_pisma: nil,
#      data_nadania: nil,
#      data_wplyniecia: DateTime.now.to_date,
#      znak_pisma_wplywajacego: nil,
#      identyfikator_typu_dcmd: 1,
#      identyfikator_rodzaju_dokumentu: 1,
#      identyfikator_sposobu_przeslania: 1,
#      identyfikator_miejsca_przechowywania: nil, #t.integer 
#      termin_na_odpowiedz: nil,
#      pelna_wersja_cyfrowa: true,
#      naturalny_elektroniczny: false,
#      liczba_zalacznikow: 0,
#      uwagi: nil,
#      identyfikator_osoby: nil,
#      identyfikator_adresu: nil,
#      esod_contractor: nil,
#      esod_address: nil,
#      initialized_from_esod: nil,
#      netpar_user: nil )

    # for outgoing_letter_add action
    @esod_outgoing_letter = @exam.esod_matters.last.esod_outgoing_letters.new(nrid: nil)

    # for internal_letter_add action
    @esod_internal_letter = @exam.esod_matters.last.esod_internal_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@exam.number}, #{@exam.place_exam}, [#{@exam.esod_category_name}]",
      identyfikator_rodzaju_dokumentu_wewnetrznego: nil,
      identyfikator_typu_dcmd: 1,
      identyfikator_dostepnosci_dokumentu: 1,
      uwagi: nil,
      pelna_wersja_cyfrowa: true,
      initialized_from_esod: nil,
      netpar_user: nil )
    end

    def exam_params
      params.require(:exam).permit(:esod_category, :number, :date_exam, :place_exam, :info, :chairman, :secretary, :category, :note, :user_id, 
        :province_id, :max_examinations, :online, examiners_attributes: [:id, :name, :_destroy], division_ids: []).tap do |tap_xx|

      # INSERT
      # {"esod_category"=>"47", "number"=>"73/21/A", "date_exam"=>"2021-12-03", "place_exam"=>"UKE Poznań", "province_id"=>"04", 
      #   "info"=>"ul. Kasprzaka 54, godz. 13:00", "max_examinations"=>"4", "chairman"=>"A", "secretary"=>"B", 
      #     "examiners_attributes"=>{
      #       "1635237929099"=>{"name"=>"C1", "_destroy"=>"false"}, 
      #       "1635237934309"=>{"name"=>"C2", "_destroy"=>"false"}}, 
      #   "note"=>"", 
      #     "division_ids"=>["18", "20", ""]}

      # UPDATE
      # {"esod_category"=>"47", "number"=>"73/21/A", "date_exam"=>"2021-12-03", "place_exam"=>"UKE Poznań", "province_id"=>"04", 
      #   "info"=>"ul. Kasprzaka 54, godz. 13:00", "max_examinations"=>"4", "chairman"=>"A", "secretary"=>"B", 
      #     "examiners_attributes"=>{
      #       "0"=>{"name"=>"C1", "_destroy"=>"false", "id"=>"6342"}, 
      #       "1"=>{"name"=>"C2", "_destroy"=>"false", "id"=>"6343"}, 
      #       "1635238843867"=>{"name"=>"C3", "_destroy"=>"false"}}, 
      #     "note"=>"", 
      #       "division_ids"=>["18", "20", ""]}      

        # exams_divisions_attributes:
        # {"0"=>{"division_id"=>"18", "_destroy"=>"false", "id"=>"6342"}, 
        #  "1"=>{"division_id"=>"20", "_destroy"=>"true", "id"=>"6343"}, 
        #  "1635238843867"=>{"division_id"=>"21", "_destroy"=>"false"}}

        divisions_ids_array = tap_xx.fetch(:division_ids).reject(&:empty?).map(&:to_i)
        exams_divisions = ExamsDivision.where(exam_id: params[:id])
        exams_divisions_array = exams_divisions.pluck(:division_id)
        exams_divisions_attr = {}

        # new
        (divisions_ids_array - exams_divisions_array).each do |x|
          # Jest OK - zastosuj jeżeli nie budujesz elementów z poziomu modelu.           
          # exams_divisions_subjects_attr = {}
          # Division.find(x).subjects.order(:item).each do |subiect|
          #   exams_divisions_subjects_attr[exams_divisions_subjects_attr.size.to_s] = {subject_id: subiect.id, _destroy: "false"}
          # end
          # exams_divisions_attr[(exams_divisions_attr.size).to_s] = {division_id: x, _destroy: "false", exams_divisions_subjects_attributes: exams_divisions_subjects_attr}
          exams_divisions_attr[(exams_divisions_attr.size).to_s] = {division_id: x, _destroy: "false"}
        end

        # delete
        (exams_divisions_array - divisions_ids_array).each do |x|
          exams_divisions_attr[(exams_divisions_attr.size).to_s] = {division_id: x, _destroy: "true", id: "#{exams_divisions.find_by(division_id: x).id}"}
        end

        # no change
        (exams_divisions_array & divisions_ids_array).each do |x|
          exams_divisions_attr[(exams_divisions_attr.size).to_s] = {division_id: x, _destroy: "false", id: "#{exams_divisions.find_by(division_id: x).id}"}
        end

        tap_xx.delete :division_ids
        tap_xx[:exams_divisions_attributes] = exams_divisions_attr
      end

    end

end
