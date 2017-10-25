class CertificatesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:show_charts, :index, :datatables_index, :datatables_index_exam, :select2_index, :search]

  before_action :set_certificate, only: [:show, :edit, :update, :destroy, :certificate_to_pdf, :esod_matter_link]
  before_action :set_esod_user_id, only: [:show]


  def show_charts
    respond_to do |format|
      format.html{ render :show_charts }
    end
  end

  # GET /certificates
  # GET /certificates.json
  def index
    certificate_authorize(:certificate, "index", params[:category_service])
    # dane pobierane z datatables_index
    # @certificates = Certificate.all
  end

  def datatables_index
    respond_to do |format|
      #format.json{ render json: CertificateDatatable.new(view_context, {category_scope: params[:category] }) }
      format.json{ render json: CertificateDatatable.new(view_context) }
    end
  end

  def datatables_index_exam
    respond_to do |format|
      format.json{ render json: ExamCertificatesDatatable.new(view_context, { only_for_current_exam_id: params[:exam_id] }) }
    end
  end

  def select2_index
    params[:q] = params[:q]
    @certificates = Certificate.order(:number).finder_certificate(params[:q], (params[:category_service]).upcase)
    @certificates_on_page = @certificates.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { 
        render json: @certificates_on_page, each_serializer: CertificateSerializer, meta: {total_count: @certificates.count}
      } 
    end
#    respond_to do |format|
#      format.html
#      format.json { 
#        render json: { 
#          certificates: @certificates_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
#          total_count: @certificates.count 
#        } 
#      }
#    end
  end

  def search
    @certificates = Certificate.order(:number).finder_certificate(params[:q], (params[:category_service]).upcase)

    respond_to do |format|
      format.json { 
        render json: { 
          certificates: @certificates.as_json(only: [:id, :number, :date_of_issue, :valid_thru], include: {division: {only: [:name]}, customer: {only: [:id, :name, :given_names, :birth_date, :birth_place, :father_name]}} ),
          total_count: @certificates.count 
        } 
      }
    end
  end

  def certificate_to_pdf
    certificate_authorize(:certificate, "print", params[:category_service])

    @certificates_all = Certificate.joins(:customer).references(:customer).where(id: params[:id]).all

    if @certificates_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      documentname = "Certificate_#{params[:category_service]}_#{@certificates_all.first.number}.pdf"
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
      @certificate.works.create!(trackable_url: "#{certificate_path(@certificate, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: "certificate", filename: "#{documentname}"}.to_json)

    end 
  end

  # GET /certificates/1
  # GET /certificates/1.json
  def show
    certificate_authorize(@certificate, "show", params[:category_service])

    @esod_matter = @certificate.esod_matters.new(
      nrid: nil,
      znak: nil,
      znak_sprawy_grupujacej: nil,
      symbol_jrwa: Esodes::esod_matter_service_jrwa(@certificate.category).to_s,
      tytul: "#{@certificate.customer.name} #{@certificate.customer.given_names}, #{@certificate.customer.address_city}",
      termin_realizacji: @certificate.exam.date_exam + Esodes::limit_time_add_to_certificate(@certificate.category),
      identyfikator_kategorii_sprawy: @certificate.category == 'L' ? Esodes::SWIADECTWO_BEZ_EGZAMINU : Esodes::DUPLIKAT,
      identyfikator_stanowiska_referenta: nil,
      czy_otwarta: true,
      initialized_from_esod: nil,
      netpar_user: nil )

    @esod_matter.esod_matter_notes.build

    # for incoming_letter_add action
    @esod_incoming_letter = @certificate.esod_matters.last.esod_incoming_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@certificate.customer.name} #{@certificate.customer.given_names}, #{@certificate.customer.address_city}, [#{@certificate.esod_category_name}]",
      data_pisma: nil,
      data_nadania: nil,
      data_wplyniecia: DateTime.now.to_date,
      znak_pisma_wplywajacego: nil,
      identyfikator_typu_dcmd: 1,
      identyfikator_rodzaju_dokumentu: 1,
      identyfikator_sposobu_przeslania: 1,
      identyfikator_miejsca_przechowywania: nil, #t.integer 
      termin_na_odpowiedz: nil,
      pelna_wersja_cyfrowa: true,
      naturalny_elektroniczny: false,
      liczba_zalacznikow: 0,
      uwagi: nil,
      identyfikator_osoby: nil,
      identyfikator_adresu: nil,
      esod_contractor: nil,
      esod_address: nil,
      initialized_from_esod: nil,
      netpar_user: nil )

    # for outgoing_letter_add action
    @esod_outgoing_letter = @certificate.esod_matters.last.esod_outgoing_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@certificate.customer.name} #{@certificate.customer.given_names}, #{@certificate.customer.address_city}, [#{@certificate.esod_category_name}], #{@certificate.number}",
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
    @esod_internal_letter = @certificate.esod_matters.last.esod_internal_letters.new(
      nrid: nil,
      numer_ewidencyjny: nil,
      tytul: "#{@certificate.customer.name} #{@certificate.customer.given_names}, #{@certificate.customer.address_city}, [#{@certificate.esod_category_name}], #{@certificate.number}",
      identyfikator_rodzaju_dokumentu_wewnetrznego: nil,
      identyfikator_typu_dcmd: 1,
      identyfikator_dostepnosci_dokumentu: 1,
      uwagi: nil,
      pelna_wersja_cyfrowa: true,
      initialized_from_esod: nil,
      netpar_user: nil )

     
    respond_to do |format|
      format.html { render :show, locals: { back_url: params[:back_url]} }
      # for jBuilder
      #format.json 
      # if using active_model_serializer
      format.json { render json: @certificate, root: false, include: [] }
    end
    # przepych
    # @certificate.works.create!(trackable_url: "#{certificate_path(@certificate, category_service: params[:category_service])}", action: :show, user: current_user, parameters: {})
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
    @certificate.category = (params[:category_service]).upcase
    @certificate.date_of_issue = DateTime.now.to_date

    certificate_authorize(@certificate, "new", params[:category_service])

    @esod_matter = load_esod_matter
    if @esod_matter.present?
      @certificate.esod_category = @esod_matter.identyfikator_kategorii_sprawy
    end

    @exam = load_exam
    @certificate.exam = @exam

    @customer = load_customer
    @certificate.customer = @customer

    respond_to do |format|
      format.json
      format.html { render :new, locals: { back_url: params[:back_url] } }
    end
  end

  # GET /certificates/1/edit
  def edit
    certificate_authorize(@certificate, "edit", params[:category_service])
 
#    @esod_matter = load_esod_matter 
#    if @esod_matter.present? && @esod_matter != @certificate.esod_matter
#      @certificate.esod_matter = @esod_matter
#      @certificate.esod_category = @esod_matter.identyfikator_kategorii_sprawy
#    end

    respond_to do |format|
      format.json
      format.html { render :edit, locals: { back_url: params[:back_url] } }
    end
  end

  # POST /certificates
  # POST /certificates.json
  def create
    @certificate = Certificate.new(certificate_params)
    @certificate.category = (params[:category_service]).upcase
    @certificate.user = current_user
    @certificate.number = Certificate.next_certificate_number(params[:category_service], @certificate.division) if @certificate.number.empty?

    certificate_authorize(@certificate, "create", params[:category_service])

    respond_to do |format|
      if @certificate.save
        @certificate.works.create!(trackable_url: "#{certificate_path(@certificate, category_service: params[:category_service])}", action: :create, user: current_user, 
          parameters: @certificate.to_json(except: [:exam_id, :division_id, :customer_id, :user_id], 
                                          include: {
                                            exam: {only: [:id, :number, :date_exam]},
                                            division: {only: [:id, :name]},
                                            customer: {only: [:id, :name, :given_names, :birth_date]},
                                            user: {only: [:id, :name, :email]}
                                            }
                                          ) )

        flash_message :success, t('activerecord.messages.successfull.created', data: @certificate.number)
        format.html { redirect_to certificate_path(@certificate, category_service: params[:category_service], back_url: params[:back_url]) }
        format.json { render :show, status: :created, location: @certificate }
      else
        format.html { render :new, locals: { back_url: params[:back_url] } }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certificates/1
  # PATCH/PUT /certificates/1.json
  def update
    @certificate.user = current_user
 
    certificate_authorize(@certificate, "update", params[:category_service])

    respond_to do |format|
      if @certificate.update(certificate_params)
        @certificate.works.create!(trackable_url: "#{certificate_path(@certificate, category_service: params[:category_service])}", action: :update, user: current_user, 
          parameters: @certificate.to_json(except: [:exam_id, :division_id, :customer_id, :user_id], 
                                          include: {
                                            exam: {only: [:id, :number, :date_exam]},
                                            division: {only: [:id, :name]},
                                            customer: {only: [:id, :name, :given_names, :birth_date]},
                                            user: {only: [:id, :name, :email]}
                                            }
                                          ) )

        flash_message :success, t('activerecord.messages.successfull.updated', data: @certificate.number)
        format.html { redirect_to certificate_path(@certificate, category_service: params[:category_service], back_url: params[:back_url]) }
        format.json { render :show, status: :ok, location: @certificate }
      else
        format.html { render :edit, locals: { back_url: params[:back_url] } }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /certificates/:id/esod_matter_link
  def esod_matter_link
    certificate_authorize(@certificate, "update", params[:category_service])
    @esod_matter = Esod::Matter.find_by(id: params[:source_id])
    @esod_matter.certificate = @certificate

    if @esod_matter.save
      incoming_letter = @esod_matter.esod_incoming_letters.last
      if incoming_letter.present?
        address = incoming_letter.esod_address
        contractor = incoming_letter.esod_contractor 
 
        address.update_columns(customer_id: @esod_matter.certificate.customer_id) if address.customer_id.blank?
        contractor.update_columns(customer_id: @esod_matter.certificate.customer_id) if contractor.customer_id.blank?
      end

      @esod_matter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :esod_matter_link, user: current_user, 
                            parameters: {esod_matter: @esod_matter.fullname, link: @certificate.fullname}.to_json)

      flash_message :success, t('activerecord.messages.successfull.esod_matter_link', parent: @certificate.fullname, child: @esod_matter.fullname)
      redirect_to :back
    else
      flash_message :error, t('activerecord.messages.error.esod_matter_link', parent: @certificate.fullname, child: @esod_matter.fullname)
      redirect_to :back
    end
  end

  # DELETE /certificates/1
  # DELETE /certificates/1.json
  def destroy
    certificate_authorize(@certificate, "destroy", params[:category_service])

    exam = @certificate.exam
    if @certificate.destroy
      Work.create!(trackable: @certificate, action: :destroy, user: current_user, 
          parameters: @certificate.to_json(except: [:exam_id, :division_id, :customer_id, :user_id], 
                                          include: {
                                            exam: {only: [:id, :number, :date_exam]},
                                            division: {only: [:id, :name]},
                                            customer: {only: [:id, :name, :given_names, :birth_date]},
                                            user: {only: [:id, :name, :email]}
                                            }
                                          ) )

      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @certificate.number)
      redirect_to (params[:back_url]).present? ? params[:back_url] : exam_path(exam, category_service: params[:category_service])
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @certificate.number)
      render :show
    end      
  end

  private
    def certificate_authorize(model_class, action, category)
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

    def set_certificate
      params[:id] = params[:certificate_id] if params[:certificate_id].present?
      @certificate = Certificate.find(params[:id])
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
    def certificate_params
      params.require(:certificate).permit(:esod_category, :number, :date_of_issue, :valid_thru, :canceled, :division_id, :exam_id, :customer_id, :category, :note, :user_id)
    end
end
