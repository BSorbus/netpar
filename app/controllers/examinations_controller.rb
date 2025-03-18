require 'esodes'

class ExaminationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index_exam]

  before_action :set_examination, only: [:show, :edit, :update, :destroy, :esod_matter_link]
  before_action :set_esod_user_id, only: [:show]

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

    @esod_matter = @examination.esod_matters.new(
      nrid: nil,
      znak: nil,
      znak_sprawy_grupujacej: nil,
      symbol_jrwa: Esodes::esod_matter_service_jrwa(@examination.category).to_s,
      tytul: "#{@examination.customer.name} #{@examination.customer.given_names}, #{@examination.customer.address_city}",
      termin_realizacji: @examination.exam.date_exam + Esodes::limit_time_add_to_examination(@examination.category),
      identyfikator_kategorii_sprawy: Esodes::EGZAMIN,
      identyfikator_stanowiska_referenta: nil,
      czy_otwarta: true,
      initialized_from_esod: nil,
      netpar_user: nil )

    @esod_matter.esod_matter_notes.build(tytul: @examination.exam.number)



    # for incoming_letter_add action
    @esod_incoming_letter = @examination.esod_matters.last.esod_incoming_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@examination.customer.name} #{@examination.customer.given_names}, #{@examination.customer.address_city}, [#{@examination.esod_category_name}]",
      data_pisma: @examination.proposal.present? ? @examination.proposal.created_at.to_date : nil,
      data_nadania: @examination.proposal.present? ? @examination.proposal.created_at.to_date : nil,
      data_wplyniecia: @examination.proposal.present? ? @examination.proposal.created_at.to_date : DateTime.now.to_date,
      znak_pisma_wplywajacego: nil,
      identyfikator_typu_dcmd: 1,
      identyfikator_rodzaju_dokumentu: 244,
      identyfikator_sposobu_przeslania: @examination.proposal.present? ? Esodes::DEFAULT_SPOSOB_PRZESLANIA_IF_PROPOSAL : 1,
      identyfikator_miejsca_przechowywania: nil, #t.integer 
      termin_na_odpowiedz: nil,
      pelna_wersja_cyfrowa: true,
      naturalny_elektroniczny: @examination.proposal.present? ? true : false,
      liczba_zalacznikow: 0,
      uwagi: nil,
      identyfikator_osoby: nil,
      identyfikator_adresu: nil,
      esod_contractor: nil,
      esod_address: nil,
      initialized_from_esod: nil,
      netpar_user: nil )

    # for outgoing_letter_add action
    @esod_outgoing_letter = @examination.esod_matters.last.esod_outgoing_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@examination.customer.name} #{@examination.customer.given_names}, #{@examination.customer.address_city}, [#{@examination.esod_category_name}]",
      identyfikator_adresu: nil,
      identyfikator_sposobu_wysylki: nil,
      identyfikator_rodzaju_dokumentu_wychodzacego: nil,
      data_pisma:  DateTime.now.to_date,
      numer_wersji: nil,
      uwagi: nil,
      zakoncz_sprawe: true, 
      zaakceptuj_dokument: true,
      initialized_from_esod: nil,
      netpar_user: nil )

    # for internal_letter_add action
    @esod_internal_letter = @examination.esod_matters.last.esod_internal_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@examination.customer.name} #{@examination.customer.given_names}, #{@examination.customer.address_city}, [#{@examination.esod_category_name}]",
      identyfikator_rodzaju_dokumentu_wewnetrznego: nil,
      identyfikator_typu_dcmd: 1,
      identyfikator_dostepnosci_dokumentu: 1,
      uwagi: nil,
      pelna_wersja_cyfrowa: true,
      initialized_from_esod: nil,
      netpar_user: nil )


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

    # jesli jest nierozpatrzone elektroniczne zgloszenie z takimi parametrami
    finded_proposal = @examination.is_in_proposals_with_status_created

    if finded_proposal.present?
      flash_message :error, t('activerecord.messages.error.is_in_proposals_with_status_created')
      redirect_to proposal_path(params[:category_service], finded_proposal)
    else
      if @examination.exam.online?
        flash_message :error, t('activerecord.messages.error.if_parent_exam_is_online_examination_created_only_via_proposal')
        redirect_to proposals_path(params[:category_service])
      else
        respond_to do |format|
          if @examination.save_and_grades_add
            @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :create, user: current_user, 
              parameters: @examination.attributes.to_json)
            flash_message :success, t('activerecord.messages.successfull.created', data: @examination.fullname)

            format.html { redirect_to examination_path(@examination, category_service: params[:category_service], back_url: params[:back_url]) }
            format.json { render :show, status: :created, location: @examination }
          else
            format.html { render :new, locals: { back_url: params[:back_url]} }
            format.json { render json: @examination.errors, status: :unprocessable_entity }
          end
        end
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

        flash_message :success, t('activerecord.messages.successfull.updated', data: @examination.fullname)
        format.html { redirect_to examination_path(@examination, category_service: params[:category_service], back_url: params[:back_url]) }
        format.json { render :show, status: :ok, location: @examination }
      else
        format.html { render :edit, locals: { back_url: params[:back_url]} }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  def esod_matter_link_test
    examination_authorize(@examination, "update", params[:category_service])
    @esod_matter = Esod::Matter.find_by(id: params[:source_id])
    Esodes::esod_whenever_sprawy(current_user.id, 30.days)
  end

  # POST /examinations/:id/esod_matter_link
  def esod_matter_link
    examination_authorize(@examination, "update", params[:category_service])
    @esod_matter = Esod::Matter.find_by(id: params[:source_id])
    @esod_matter.examination = @examination

    if @esod_matter.save
      incoming_letter = @esod_matter.esod_incoming_letters.last
      if incoming_letter.present?
        address = incoming_letter.esod_address
        contractor = incoming_letter.esod_contractor 

        address.update_columns(customer_id: @esod_matter.examination.customer_id) if address.customer_id.blank?
        contractor.update_columns(customer_id: @esod_matter.examination.customer_id) if contractor.customer_id.blank?
      end

      @esod_matter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :esod_matter_link, user: current_user, 
                            parameters: {esod_matter: @esod_matter.fullname, link: @examination.fullname}.to_json)

      flash_message :success, t('activerecord.messages.successfull.esod_matter_link', parent: @examination.fullname, child: @esod_matter.fullname)
      redirect_to :back 
    else
      flash_message :error, t('activerecord.messages.error.esod_matter_link', parent: @examination.fullname, child: @esod_matter.fullname)
      redirect_to :back 
    end
  end

  # DELETE /examinations/1
  # DELETE /examinations/1.json
  def destroy
    examination_authorize(@examination, "destroy", params[:category_service])

    exam = @examination.exam
    if @examination.destroy
      Work.create!(trackable: @examination, action: :destroy, user: current_user, parameters: @examination.attributes.to_json)
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @examination.fullname)
      redirect_to (params[:back_url]).present? ? params[:back_url] : exam_path(exam, category_service: params[:category_service])
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @examination.fullname)
      render :show
    end      
  end

  def statistic_filter
    examination_authorize(:examination, "print", params[:category_service])

    respond_to do |format|
      format.html { render :statistic_filter }
    end
  end

  def statistic_to_pdf
    examination_authorize(:examination, "print", params[:category_service])

    if (params[:date_start]).blank? || (params[:date_end]).blank?
      flash_message :error, 'Musisz zdefiniować parametry "Data od" i "Data do"'
      render 'statistic_filter.html.erb'
    else
      respond_to do |format|
        format.pdf do
          pdf = PdfExaminationStatistic.new(params[:category_service], params[:date_start], params[:date_end], view_context)
          send_data pdf.render,
          filename: "Report_#{params[:category_service]}_#{params[:date_start]}_#{params[:date_end]}.pdf",
          type: "application/pdf",
          disposition: "inline"
        end
      end
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
    # For cooperation with ESOD
    def set_esod_user_id
      Esodes::EsodTokenData.new(current_user.id)
    end

    def set_examination
      @examination = Examination.find(params[:id])
    end

    def load_exam
      Exam.find(params[:exam_id]) if (params[:exam_id]).present?
    end

    def load_customer
      Customer.find(params[:customer_id]) if (params[:customer_id]).present?
    end

    def load_esod_matter
      Esod::Matter.find(params[:esod_matter_id]) if (params[:esod_matter_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def examination_params
      params.require(:examination).permit(:esod_category, :division_id, :exam_id, :customer_id, :examination_result, :certificate_id, :note, :category, :exam_id, :user_id, grades_attributes: [:id, :grade_result])
    end
end
