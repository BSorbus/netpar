class Esod::IncomingLettersController < ApplicationController
  before_action :set_esod_incoming_letter, only: [:show, :edit, :update, :destroy]

  # GET /esod/incoming_letters
  # GET /esod/incoming_letters.json
  def index
    @esod_incoming_letters = Esod::IncomingLetter.all
  end

  # GET /esod/incoming_letters/1
  # GET /esod/incoming_letters/1.json
  def show
  end

  # GET /esod/incoming_letters/new
  def new
    @esod_incoming_letter = Esod::IncomingLetter.new
  end

  # GET /esod/incoming_letters/1/edit
  def edit
  end

  # POST /esod/incoming_letters
  # POST /esod/incoming_letters.json
  def create
    @esod_incoming_letter = Esod::IncomingLetter.new(esod_incoming_letter_params)

    respond_to do |format|
      if @esod_incoming_letter.save
        format.html { redirect_to @esod_incoming_letter, notice: 'Incoming letter was successfully created.' }
        format.json { render :show, status: :created, location: @esod_incoming_letter }
      else
        format.html { render :new }
        format.json { render json: @esod_incoming_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod/incoming_letters/1
  # PATCH/PUT /esod/incoming_letters/1.json
  def update
    respond_to do |format|
      if @esod_incoming_letter.update(esod_incoming_letter_params)
        format.html { redirect_to @esod_incoming_letter, notice: 'Incoming letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_incoming_letter }
      else
        format.html { render :edit }
        format.json { render json: @esod_incoming_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod/incoming_letters/1
  # DELETE /esod/incoming_letters/1.json
  def destroy
    @esod_incoming_letter.destroy
    respond_to do |format|
      format.html { redirect_to esod_incoming_letters_url, notice: 'Incoming letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_incoming_letter
      @esod_incoming_letter = Esod::IncomingLetter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_incoming_letter_params
      params.require(:esod_incoming_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :data_pisma, :data_nadania, :data_wplyniecia, :znak_pisma_wplywajacego, :identyfikator_typu_dcmd, :identyfikator_rodzaju_dokumentu, :identyfikator_sposobu_przeslania, :identyfikator_miejsca_przechowywania, :termin_na_odpowiedz, :pelna_wersja_cyfrowa, :naturalny_elektroniczny, :uwagi, :id_osoba, :id_adres, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :esod_contractor_id, :esod_address_id, :initialized_from_esod, :netpar_user)
    end
end
