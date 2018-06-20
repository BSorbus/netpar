class Esod::ContractorsController < ApplicationController
  before_action :set_esod_contractor, only: [:show, :edit, :update, :destroy]

  # GET /esod/contractors
  # GET /esod/contractors.json
  def index
    @esod_contractors = Esod::Contractor.all
  end

  # GET /esod/contractors/1
  # GET /esod/contractors/1.json
  def show
  end

  # GET /esod/contractors/new
  def new
    @esod_contractor = Esod::Contractor.new
  end

  # GET /esod/contractors/1/edit
  def edit
  end

  # POST /esod/contractors
  # POST /esod/contractors.json
  def create
    @esod_contractor = Esod::Contractor.new(esod_contractor_params)

    respond_to do |format|
      if @esod_contractor.save
        format.html { redirect_to @esod_contractor, notice: 'Contractor was successfully created.' }
        format.json { render :show, status: :created, location: @esod_contractor }
      else
        format.html { render :new }
        format.json { render json: @esod_contractor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod/contractors/1
  # PATCH/PUT /esod/contractors/1.json
  def update
    respond_to do |format|
      if @esod_contractor.update(esod_contractor_params)
        format.html { redirect_to @esod_contractor, notice: 'Contractor was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_contractor }
      else
        format.html { render :edit }
        format.json { render json: @esod_contractor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod/contractors/1
  # DELETE /esod/contractors/1.json
  def destroy
    @esod_contractor.destroy
    respond_to do |format|
      format.html { redirect_to esod_contractors_url, notice: 'Contractor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_contractor
      @esod_contractor = Esod::Contractor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_contractor_params
      params.require(:esod_contractor).permit(:nrid, :imie, :nazwisko, :nazwa, :drugie_imie, :tytul, :nip, :pesel, :rodzaj, :initialized_from_esod, :netpar_user)
    end
end
