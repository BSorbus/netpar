class Esod::OutgoingLettersController < ApplicationController
  before_action :set_esod_outgoing_letter, only: [:show, :edit, :update, :destroy]

  # GET /esod/outgoing_letters
  # GET /esod/outgoing_letters.json
  def index
    @esod_outgoing_letters = Esod::OutgoingLetter.all
  end

  # GET /esod/outgoing_letters/1
  # GET /esod/outgoing_letters/1.json
  def show
  end

  # GET /esod/outgoing_letters/new
  def new
    @esod_outgoing_letter = Esod::OutgoingLetter.new
  end

  # GET /esod/outgoing_letters/1/edit
  def edit
  end

  # POST /esod/outgoing_letters
  # POST /esod/outgoing_letters.json
  def create
    @esod_outgoing_letter = Esod::OutgoingLetter.new(esod_outgoing_letter_params)

    respond_to do |format|
      if @esod_outgoing_letter.save
        format.html { redirect_to @esod_outgoing_letter, notice: 'Outgoing letter was successfully created.' }
        format.json { render :show, status: :created, location: @esod_outgoing_letter }
      else
        format.html { render :new }
        format.json { render json: @esod_outgoing_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod/outgoing_letters/1
  # PATCH/PUT /esod/outgoing_letters/1.json
  def update
    respond_to do |format|
      if @esod_outgoing_letter.update(esod_outgoing_letter_params)
        format.html { redirect_to @esod_outgoing_letter, notice: 'Outgoing letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_outgoing_letter }
      else
        format.html { render :edit }
        format.json { render json: @esod_outgoing_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod/outgoing_letters/1
  # DELETE /esod/outgoing_letters/1.json
  def destroy
    @esod_outgoing_letter.destroy
    respond_to do |format|
      format.html { redirect_to esod_outgoing_letters_url, notice: 'Outgoing letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_outgoing_letter
      @esod_outgoing_letter = Esod::OutgoingLetter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_outgoing_letter_params
      params.require(:esod_outgoing_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :wysylka, :identyfikator_rodzaju_dokumentu_wychodzacego, :data_pisma, :numer_wersji, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user)
    end
end
