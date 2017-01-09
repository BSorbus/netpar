class Teryt::PnaCodesController < ApplicationController
  before_action :authenticate_user!
  #after_action :verify_authorized, except: [:index, :datatables_index, :select2_index]

  before_action :set_teryt_pna_code, only: [:show, :edit, :update, :destroy]


  # GET /teryt/pna_codes
  # GET /teryt/pna_codes.json
  def index
    @teryt_pna_codes = Teryt::PnaCode.all
  end

  def select2_index
    params[:q] = params[:q]
    @teryt_pna_codes = Teryt::PnaCode.order(:mie_nazwa, :uli_nazwa, :pna).finder_teryt_pna_code(params[:q])
    @teryt_pna_codes_on_page = @teryt_pna_codes.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { render json: @teryt_pna_codes_on_page, each_serializer: Teryt::PnaCodeSerializer, meta: {total_count: @teryt_pna_codes.count} } 
    end
  end

  # GET /teryt/pna_codes/1
  # GET /teryt/pna_codes/1.json
  def show
    #authorize @customer, :show?

    respond_to do |format|
      format.json { render json: @teryt_pna_code, root: false, include: [] }
    end
  end

  # GET /teryt/pna_codes/new
  def new
    @teryt_pna_code = Teryt::PnaCode.new
  end

  # GET /teryt/pna_codes/1/edit
  def edit
  end

  # POST /teryt/pna_codes
  # POST /teryt/pna_codes.json
  def create
    @teryt_pna_code = Teryt::PnaCode.new(teryt_pna_code_params)

    respond_to do |format|
      if @teryt_pna_code.save
        format.html { redirect_to @teryt_pna_code, notice: 'Postal code was successfully created.' }
        format.json { render :show, status: :created, location: @teryt_pna_code }
      else
        format.html { render :new }
        format.json { render json: @teryt_pna_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teryt/pna_codes/1
  # PATCH/PUT /teryt/pna_codes/1.json
  def update
    respond_to do |format|
      if @teryt_pna_code.update(teryt_pna_code_params)
        format.html { redirect_to @teryt_pna_code, notice: 'Postal code was successfully updated.' }
        format.json { render :show, status: :ok, location: @teryt_pna_code }
      else
        format.html { render :edit }
        format.json { render json: @teryt_pna_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teryt/pna_codes/1
  # DELETE /teryt/pna_codes/1.json
  def destroy
    @teryt_pna_code.destroy
    respond_to do |format|
      format.html { redirect_to teryt_pna_codes_url, notice: 'Postal code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teryt_pna_code
      @teryt_pna_code = Teryt::PnaCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teryt_pna_code_params
      params.require(:teryt_pna_code).permit(:pna, :woj_nazwa, :pow_nazwa, :gmi_nazwa, :sym_nazwa, :sympod_nazwa, :mie_nazwa, :uli_nazwa, :numery, :teryt, :pna_teryt)
    end
end
