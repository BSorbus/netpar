class Esod::InternalLettersController < ApplicationController
  before_action :set_esod_internal_letter, only: [:show, :edit, :update, :destroy]

  # GET /esod/internal_letters
  # GET /esod/internal_letters.json
  def index
    @esod_internal_letters = Esod::InternalLetter.all
  end

  # GET /esod/internal_letters/1
  # GET /esod/internal_letters/1.json
  def show
  end

  # GET /esod/internal_letters/new
  def new
    @esod_internal_letter = Esod::InternalLetter.new
  end

  # GET /esod/internal_letters/1/edit
  def edit
  end

  # POST /esod/internal_letters
  # POST /esod/internal_letters.json
  def create
    @esod_internal_letter = Esod::InternalLetter.new(esod_internal_letter_params)

    respond_to do |format|
      if @esod_internal_letter.save
        format.html { redirect_to @esod_internal_letter, notice: 'Internal letter was successfully created.' }
        format.json { render :show, status: :created, location: @esod_internal_letter }
      else
        format.html { render :new }
        format.json { render json: @esod_internal_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod/internal_letters/1
  # PATCH/PUT /esod/internal_letters/1.json
  def update
    respond_to do |format|
      if @esod_internal_letter.update(esod_internal_letter_params)
        format.html { redirect_to @esod_internal_letter, notice: 'Internal letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_internal_letter }
      else
        format.html { render :edit }
        format.json { render json: @esod_internal_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod/internal_letters/1
  # DELETE /esod/internal_letters/1.json
  def destroy
    @esod_internal_letter.destroy
    respond_to do |format|
      format.html { redirect_to esod_internal_letters_url, notice: 'Internal letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_internal_letter
      @esod_internal_letter = Esod::InternalLetter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_internal_letter_params
      params.require(:esod_internal_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :uwagi, :identyfikator_rodzaju_dokumentu_wewnetrznego, :identyfikator_typu_dcmd, :identyfikator_dostepnosci_dokumentu, :pelna_wersja_cyfrowa, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user)
    end
end
