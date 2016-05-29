class EsodIncomingLettersController < ApplicationController
  before_action :authenticate_user!

  def create
    if @incoming_letterable.esod_matters.empty?
      respond_to do |format|
        format.html { redirect_to :back, alert: "Nie ma spraw! Pismo jest tworzone do ostatniej sprawy" }
      end
    else
      @esod_matter = @incoming_letterable.esod_matters.last

      @esod_incoming_letter = @incoming_letterable.esod_matters.last.esod_incoming_letters.new(esod_incoming_letter_params)
      @esod_incoming_letter.initialized_from_esod = false
      @esod_incoming_letter.netpar_user = current_user.id

      # wywolaj funkce zapisujaca contractora i address do ESODA
      @incoming_letterable.customer.check_and_push_data_to_esod(push_user: current_user.id)

      @esod_incoming_letter.identyfikator_osoby = @incoming_letterable.customer.esod_contractor.nrid
      @esod_incoming_letter.identyfikator_adresu = @incoming_letterable.customer.esod_address.nrid

      respond_to do |format|
        if @esod_incoming_letter.save 
          
          elm = @esod_incoming_letter.esod_incoming_letters_matters.create(
                  esod_matter_id: @esod_matter.id,  
                  sprawa: @esod_matter.nrid,   
                  dokument: @esod_incoming_letter.nrid,   
                  sygnatura: nil,
                  initialized_from_esod: false,
                  netpar_user: current_user.id)

          #@esod_incoming_letter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :create, user: current_user, parameters: @esod_matter.attributes.to_json)
          #format.html { redirect_to :back, notice: t('activerecord.messages.successfull.created', data: @esod_matter.znak) }
          #format.html { redirect_to :back, notice: "Utworzono pismo" }
          format.html { redirect_to :back, notice: t('activerecord.messages.successfull.created', data: elm.sygnatura) }
        else
          #format.html { render :show, alert: t('activerecord.messages.error.created') }
          format.html { redirect_to :back, alert: t('activerecord.messages.error.created') }
        end
      end
    end
  end

  private

    def esod_incoming_letter_params
      params.require(:esod_incoming_letter).permit( :nrid, :numer_ewidencyjny, :tytul, :data_pisma, :data_nadania, :data_wplyniecia, :znak_pisma_wplywajacego, 
        :identyfikator_typu_dcmd, :identyfikator_rodzaju_dokumentu, :identyfikator_sposobu_przeslania, :identyfikator_miejsca_przechowywania, :termin_na_odpowiedz,
      :pelna_wersja_cyfrowa, :naturalny_elektroniczny, :liczba_zalacznikow, :uwagi, :identyfikator_osoby, :identyfikator_adresu, :data_utworzenia, :identyfikator_osoby_tworzacej, 
      :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :esod_contractor, :esod_address, :initialized_from_esod, :netpar_user )
    end

end