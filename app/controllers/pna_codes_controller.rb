class PnaCodesController < ApplicationController
  before_action :set_pna_code, only: [:show, :edit, :update, :destroy]

  # GET /pna_codes
  # GET /pna_codes.json
  def index
    @pna_codes = PnaCode.all
  end

  def select2_index
    params[:q] = params[:q]
    @pna_codes = PnaCode.order(:pna, :miejscowosc).finder_pna_code(params[:q])
    @pna_codes_on_page = @pna_codes.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { render json: @pna_codes_on_page, each_serializer: PnaCodeSerializer, meta: {total_count: @pna_codes.count} } 
    end
  end

  # GET /pna_codes/1
  # GET /pna_codes/1.json
  def show
    #authorize @customer, :show?

    respond_to do |format|
      format.json { render json: @pna_code, root: false, include: [] }
    end
  end

  # GET /pna_codes/new
  def new
    @pna_code = PnaCode.new
  end

  # GET /pna_codes/1/edit
  def edit
  end

  # POST /pna_codes
  # POST /pna_codes.json
  def create
    @pna_code = PnaCode.new(pna_code_params)

    respond_to do |format|
      if @pna_code.save
        format.html { redirect_to @pna_code, notice: 'Postal code was successfully created.' }
        format.json { render :show, status: :created, location: @pna_code }
      else
        format.html { render :new }
        format.json { render json: @pna_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pna_codes/1
  # PATCH/PUT /pna_codes/1.json
  def update
    respond_to do |format|
      if @pna_code.update(pna_code_params)
        format.html { redirect_to @pna_code, notice: 'Postal code was successfully updated.' }
        format.json { render :show, status: :ok, location: @pna_code }
      else
        format.html { render :edit }
        format.json { render json: @pna_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pna_codes/1
  # DELETE /pna_codes/1.json
  def destroy
    @pna_code.destroy
    respond_to do |format|
      format.html { redirect_to pna_codes_url, notice: 'Postal code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pna_code
      @pna_code = PnaCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pna_code_params
      params.require(:pna_code).permit(:pna, :miejscowosc, :ulica, :numery, :wojewodztwo, :powiat, :gmina)
    end
end
