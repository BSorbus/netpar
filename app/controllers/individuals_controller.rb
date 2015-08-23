class IndividualsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_individual, only: [:show, :edit, :update, :destroy]

  # GET /individuals
  # GET /individuals.json
  def index
    @individuals = Individual.all
  end

  # POST /customers
  def datatables_index
    respond_to do |format|
      format.json{ render json: IndividualDatatable.new(view_context) }
    end
  end

  # GET /individuals/1
  # GET /individuals/1.json
  def show
    authorize @individual, :show?
  end

  # GET /individuals/new
  def new
    @individual = Individual.new
    @customer = load_customer
    @individual.customer = @customer
    authorize @individual, :new?
  end

  # GET /individuals/1/edit
  def edit
    authorize @individual, :edit?
  end

  # POST /individuals
  # POST /individuals.json
  def create
    @individual = Individual.new(individual_params)
    authorize @individual, :create?

    respond_to do |format|
      if @individual.save
        format.html { redirect_to @individual, notice: 'Individual was successfully created.' }
        format.json { render :show, status: :created, location: @individual }
      else
        format.html { render :new }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /individuals/1
  # PATCH/PUT /individuals/1.json
  def update
    authorize @individual, :update?
    respond_to do |format|
      if @individual.update(individual_params)
        format.html { redirect_to @individual, notice: 'Individual was successfully updated.' }
        format.json { render :show, status: :ok, location: @individual }
      else
        format.html { render :edit }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /individuals/1
  # DELETE /individuals/1.json
  def destroy
    @individual.destroy
    authorize @individual, :destroy?

    respond_to do |format|
      format.html { redirect_to individuals_url, notice: 'Individual was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_individual
      @individual = Individual.find(params[:id])
    end

    def load_customer
      Customer.find(params[:customer_id]) if (params[:customer_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def individual_params
      params.require(:individual).permit(:number, :date_of_issue, :valid_thru, :license_status, :application_date, :call_sign, :category, :transmitter_power, :certificate_number, :certificate_date_of_issue, :certificate_id, :payment_code, :payment_date, :station_city, :station_street, :station_house, :station_number, :customer_id, :note, :user_id)
    end
end
