class CustomersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :datatables_for_select_index, :select2_index]

  before_action :set_customer, only: [:show, :edit, :update, :destroy, :merge, :envelope_to_pdf, :history_to_pdf]

  # GET /customers
  # GET /customers.json
  def index
    # dane pobierane z datatables_index
    # @customers = Customer.all
    authorize :customer, :index?
  end

  # POST /customers
  def datatables_index
    respond_to do |format|
      format.json{ render json: CustomerDatatable.new(view_context) }
    end
  end

  # POST /customers
  def datatables_for_select_index
    respond_to do |format|
      format.json{ render json: CustomerForSelectDatatable.new(view_context) }
    end
  end

  def select2_index
    #params[:q] = (params[:q]).upcase
    params[:q] = params[:q]
    @customers = Customer.order(:name, :given_names).finder_customer(params[:q])
    @customers_on_page = @customers.page(params[:page]).per(params[:page_limit])
    
    respond_to do |format|
      format.html
      format.json { 
        render json: @customers_on_page, each_serializer: CustomerSerializer, meta: {total_count: @customers.count}  
      }
#      format.json { 
#        render json: { 
#          customers: @customers_on_page.as_json(methods: :fullname_and_address_and_pesel_nip_and_birth_date, only: [:id, :fullname_and_address_and_pesel_nip_and_birth_date]),
#          total_count: @customers.count 
#        } 
#      }
    end
  end

  # POST /customers/:id/merge
  def merge
    authorize @customer, :merge?
    if (params[:source_id]).present? && not(params[:source_id] == params[:id])
      @source = Customer.find(params[:source_id])
      @customer.join_with_another(@source)

      @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :merge, user: current_user, 
                              parameters: {source: @source.fullname_and_id, destination: @customer.fullname_and_id}.to_json)

      flash_message :success, t('activerecord.messages.successfull.merge', parent: @customer.fullname_and_id, child: @source.fullname_and_id)
      redirect_to @customer
    else
      flash_message :error, t('activerecord.messages.error.merge', data: @customer.fullname_and_id)
      redirect_to @customer
    end
  end

  def envelope_to_pdf
    authorize @customer, :show?

    @customers_all = Customer.where(id: params[:id]).all

    if @customers_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      documentname = "Envelope_#{@customers_all.first.fullname}.pdf"

      respond_to do |format|
        format.pdf do
          pdf = PdfEnvelopes.new(@customers_all, view_context)
          send_data pdf.render,
          filename: documentname,
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'envelope', filename: "#{documentname}"}.to_json)

    end 
  end

  def history_to_pdf
    authorize @customer, :work?

    @works = Work.where(trackable: @customer).where.not(action: :to_pdf).order(:created_at).all

    t1 = "Klient: #{@customer.fullname_and_id}"
    t2 = "kartoteka utworzona: #{@customer.created_at.strftime("%Y-%m-%d %H:%M:%S")}"
    t3 = "ostatnia aktualizacja: #{@customer.updated_at.strftime("%Y-%m-%d %H:%M:%S")}"
    t4 = ""

    respond_to do |format|
      format.pdf do
        pdf = PdfUserAccountHistory.new(@works, "Historia wpisów", t1, t2, t3, t4, view_context)
        send_data pdf.render,
        filename: "Customer_history_#{@customer.fullname_and_id}.pdf",
        type: "application/pdf",
        disposition: "inline"   
      end
    end
    @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :to_pdf, user: current_user, 
                      parameters: {pdf_type: 'customer_history', filename: "Customer_history_#{@customer.fullname_and_id}.pdf"}.to_json)

  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    authorize @customer, :show?

    respond_to do |format|
      # for jBuilder
      #format.json 
      # if using active_model_serializer
      format.json { render json: @customer, root: false, include: [] }
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
    # przepych
    # @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :show, user: current_user, parameters: {})
  end

  # GET /customers/new
  def new
    @customer = params[:customer].present? ? Customer.new(customer_params) : Customer.new
    @customer.lives_in_poland = true
    @customer.c_lives_in_poland = true
    authorize :customer, :new?
  end

  # GET /customers/1/edit
  def edit
    authorize @customer, :edit?
    #authorize :customer, :edit?
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    @customer.user = current_user
    authorize @customer, :create?

    respond_to do |format|
      if @customer.save
        @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :create, user: current_user, 
          parameters: @customer.to_json(except: {customer: [:fullname_and_address_and_pesel_nip_and_birth_date]}, 
                  include: { 
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        flash_message :success, t('activerecord.messages.successfull.created', data: @customer.fullname)
        format.html { redirect_to @customer }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer.user = current_user
    authorize @customer, :update?

    respond_to do |format|
      if @customer.update(customer_params)
        @customer.works.create!(trackable_url: "#{customer_path(@customer)}", action: :update, user: current_user, 
          parameters: @customer.to_json(except: {customer: [:fullname_and_address_and_pesel_nip_and_birth_date]}, 
                  include: { 
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        flash_message :success, t('activerecord.messages.successfull.updated', data: @customer.fullname)
        format.html { redirect_to @customer }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    authorize @customer, :destroy?

    if @customer.destroy
      Work.create!(trackable: @customer, action: :destroy, user: current_user, 
          parameters: @customer.to_json(except: {customer: [:fullname_and_address_and_pesel_nip_and_birth_date]}, 
                  include: { 
                    user: {
                      only: [:id, :name, :email] } 
                          }))

      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @customer.fullname)
      redirect_to customers_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @customer.fullname)
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:human, :name, :given_names, 
        :address_in_poland, :address_teryt_pna_code_id, :address_city, :address_street, :address_house, :address_number, :address_postal_code, 
        :address_post_office, :address_pobox, 
          :lives_in_poland, :address_id, :teryt_code, 
          :province_code, :province_name, :district_code, :district_name, :commune_code, :commune_name, 
          :city_code, :city_name, :city_parent_code, :city_parent_name, :street_code, :street_name, :street_attribute, :post_code, :post_code_numbers, 
        :c_address_in_poland, :c_address_teryt_pna_code_id, :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code, 
        :c_address_post_office, :c_address_pobox, 
          :c_lives_in_poland, :c_address_id, :c_teryt_code, 
          :c_province_code, :c_province_name, :c_district_code, :c_district_name, :c_commune_code, :c_commune_name, 
          :c_city_code, :c_city_name, :c_city_parent_code, :c_city_parent_name, :c_street_code, :c_street_name, :c_street_attribute, :c_post_code, :c_post_code_numbers, 
        :nip, :regon, :pesel, :birth_date, :birth_place, :fathers_name, :mothers_name, :family_name, :citizenship_code, :phone, :fax, :email, :note, :user_id)
    end
end
