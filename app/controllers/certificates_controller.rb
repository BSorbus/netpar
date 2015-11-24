class CertificatesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :datatables_index_exam, :select2_index, :search]

  before_action :set_certificate, only: [:show, :edit, :update, :destroy, :certificate_to_pdf]

  # GET /certificates
  # GET /certificates.json
  def index
    case params[:category_service]
      when 'l'
        authorize :certificate, :index_l?
      when 'm'
        authorize :certificate, :index_m?
      when 'r'
        authorize :certificate, :index_r?
    end    
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
        render json: { 
          certificates: @certificates_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
          #certificates: @certificates_on_page.as_json(only: [:id, :number, :date_of_issue]),
          total_count: @certificates.count 
        } 
      }
    end
  end

  def search
    params[:q] = params[:q]
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
    case params[:category_service]
      when 'l'
        authorize :certificate, :print_l?
      when 'm'
        authorize :certificate, :print_m?
      when 'r'
        authorize :certificate, :print_r?
    end    

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
    case params[:category_service]
      when 'l'
        authorize @certificate, :show_l?
      when 'm'
        authorize @certificate, :show_m?
      when 'r'
        authorize @certificate, :show_r?
    end   
     
    respond_to do |format|
      format.json
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
    # przepych
    # @certificate.works.create!(trackable_url: "#{certificate_path(@certificate, category_service: params[:category_service])}", action: :show, user: current_user, parameters: {})
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
    @certificate.category = (params[:category_service]).upcase
    @certificate.date_of_issue = DateTime.now.to_date

    @exam = load_exam
    @certificate.exam = @exam

    @customer = load_customer
    @certificate.customer = @customer

    case params[:category_service]
      when 'l'
        authorize @certificate, :new_l?
      when 'm'
        authorize @certificate, :new_m?
      when 'r'
        authorize @certificate, :new_r?
    end    

    respond_to do |format|
      format.json
      format.html { render :new, locals: { back_url: params[:back_url]} }
    end
  end

  # GET /certificates/1/edit
  def edit
    case params[:category_service]
      when 'l'
        authorize @certificate, :edit_l?
      when 'm'
        authorize @certificate, :edit_m?
      when 'r'
        authorize @certificate, :edit_r?
    end    
     
    respond_to do |format|
      format.json
      format.html { render :edit, locals: { back_url: params[:back_url]} }
    end
  end

  # POST /certificates
  # POST /certificates.json
  def create
    @certificate = Certificate.new(certificate_params)
    @certificate.category = (params[:category_service]).upcase
    @certificate.user = current_user
    @certificate.number = Certificate.next_certificate_number(params[:category_service], @certificate.division) if @certificate.number.empty?

    case params[:category_service]
      when 'l'
        authorize @certificate, :create_l?
      when 'm'
        authorize @certificate, :create_m?
      when 'r'
        authorize @certificate, :create_r?
    end    

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

        format.html { redirect_to certificate_path(@certificate, category_service: params[:category_service], back_url: params[:back_url]), notice: t('activerecord.messages.successfull.created', data: @certificate.number) }
        format.json { render :show, status: :created, location: @certificate }
      else
        format.html { render :new, locals: { back_url: params[:back_url]} }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certificates/1
  # PATCH/PUT /certificates/1.json
  def update
    @certificate.user = current_user
    case params[:category_service]
      when 'l'
        authorize @certificate, :update_l?
      when 'm'
        authorize @certificate, :update_m?
      when 'r'
        authorize @certificate, :update_r?
    end    

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

        format.html { redirect_to certificate_path(@certificate, category_service: params[:category_service], back_url: params[:back_url]), notice: t('activerecord.messages.successfull.updated', data: @certificate.number) }
        format.json { render :show, status: :ok, location: @certificate }
      else
        format.html { render :edit, locals: { back_url: params[:back_url]} }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certificates/1
  # DELETE /certificates/1.json
  def destroy
    case params[:category_service]
      when 'l'
        authorize @certificate, :destroy_l?
      when 'm'
        authorize @certificate, :destroy_m?
      when 'r'
        authorize @certificate, :destroy_r?
    end    

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
      redirect_to (params[:back_url]).present? ? params[:back_url] : exam_path(exam, category_service: params[:category_service]), notice: t('activerecord.messages.successfull.destroyed', data: @certificate.number)
    else 
      flash.now[:alert] = t('activerecord.messages.error.destroyed', data: @certificate.number)
      render :show
    end      
  end


#  def search_for_name
#    @resources = Customer.select([:id, :name]).
#                          where("name like :q", q: "%#{params[:q]}%").
#                          order('name').page(params[:page]).per(params[:per]) # this is why we need kaminari. of course you could also use limit().offset() instead
#   
#    # also add the total count to enable infinite scrolling
#    resources_count = Customer.select([:id, :name]).
#                          where("name like :q", q: "%#{params[:q]}%").count
#   
#    respond_to do |format|
#      format.json { render json: {total: resources_count, resources: @resources.map { |e| {id: e.id, text: "#{e.name} (#{e.pesel})"} }} }
#    end
#  end


  private
    def certificate_authorize(model_class, action, options={})
      case options[:category_service]
        when 'l'
          authorize model_class, :destroy_l?
        when 'm'
          authorize model_class, :destroy_m?
        when 'r'
          authorize model_class, :destroy_r?
      end    
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_certificate
      @certificate = Certificate.find(params[:id])
    end

    def load_exam
      Exam.find(params[:exam_id]) if (params[:exam_id]).present?
    end

    def load_customer
      Customer.find(params[:customer_id]) if (params[:customer_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def certificate_params
      params.require(:certificate).permit(:number, :date_of_issue, :valid_thru, :certificate_status, :division_id, :exam_id, :customer_id, :category, :note, :user_id)
    end
end
