class CustomersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :select2_index]

  before_action :set_customer, only: [:show, :edit, :update, :destroy, :merge]

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

  def select2_index
    #params[:q] = (params[:q]).upcase
    params[:q] = params[:q]
    @customers = Customer.order(:name, :given_names).finder_customer(params[:q])
    @customers_on_page = @customers.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          customers: @customers_on_page.as_json([]),
          total_count: @customers.count 
        } 
      }
    end
  end

  # POST /customers/:id/merge
  def merge
    authorize @customer, :merge?
    if (params[:source_id]).present? && not(params[:source_id] == params[:id])
      @source = Customer.find(params[:source_id])
      @customer.join_with_another(@source)
      redirect_to @customer, notice: t('activerecord.messages.successfull.merge', parent: @customer.fullname_and_id, child: @source.fullname_and_id)
    else
      redirect_to @customer, alert: t('activerecord.messages.error.merge', data: @customer.fullname_and_id)
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    authorize @customer, :show?
  end

  # GET /customers/new
  def new
    @customer = Customer.new
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
    authorize @customer, :create?

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: t('activerecord.messages.successfull.created', data: @customer.fullname) }
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
    authorize @customer, :update?
    
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: t('activerecord.messages.successfull.updated', data: @customer.fullname) }
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
      redirect_to customers_url, notice: t('activerecord.messages.successfull.destroyed', data: @customer.fullname)
    else 
      flash[:alert] = t('activerecord.messages.error.destroyed', data: @customer.fullname)
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
      params.require(:customer).permit(:human, :name, :given_names, :address_city, :address_street, :address_house, :address_number, :address_postal_code, :address_post_office, :address_pobox, :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code, :c_address_post_office, :c_address_pobox, :nip, :regon, :pesel, :nationality_id, :citizenship_id, :birth_date, :birth_place, :fathers_name, :mothers_name, :phone, :fax, :email, :note, :user_id, :code)
    end
end
