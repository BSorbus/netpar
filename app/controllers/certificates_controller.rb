class CertificatesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :datatables_index_exam]

  before_action :set_certificate, only: [:show, :edit, :update, :destroy]

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
      respond_to do |format|
        format.pdf do
          case params[:category_service]
            when 'l'
              pdf = PdfCertificatesL.new(@certificates_all, view_context)
            when 'm'
              pdf = PdfCertificatesM.new(@certificates_all, view_context)
            when 'r'
              pdf = PdfCertificatesR.new(@certificates_all, view_context)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: "Certificate_#{params[:category_service]}__#{@certificates_all.first.number}.pdf",
          type: "application/pdf",
          disposition: "inline"   
        end
      end
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
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
    @certificate.category = (params[:category_service]).upcase

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

    if @certificate.destroy
      redirect_to params[:back_url], notice: t('activerecord.messages.successfull.destroyed', data: @certificate.number)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @certificate.number)
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
