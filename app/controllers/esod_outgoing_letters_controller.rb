class EsodOutgoingLettersController < ApplicationController
  before_action :authenticate_user!

  def create
    if @outgoing_letterable.esod_matters.empty?
      respond_to do |format|
        format.html { redirect_to :back, alert: "Nie ma spraw! Pismo jest tworzone do ostatniej sprawy" }
      end
    else
      @esod_matter = @outgoing_letterable.esod_matters.last

      @esod_outgoing_letter = @outgoing_letterable.esod_matters.last.esod_outgoing_letters.new(esod_outgoing_letter_params)
      @esod_outgoing_letter.initialized_from_esod = false
      @esod_outgoing_letter.netpar_user = current_user.id

      # wywolaj funkce zapisujaca contractora i address do ESODA
      @outgoing_letterable.customer.check_and_push_data_to_esod(push_user: current_user.id)

      #@esod_outgoing_letter.identyfikator_osoby = @outgoing_letterable.customer.esod_contractor.nrid
      @esod_outgoing_letter.identyfikator_adresu = @outgoing_letterable.customer.esod_address.nrid

      respond_to do |format|
        if @esod_outgoing_letter.save

          elm = @esod_outgoing_letter.esod_outgoing_letters_matters.create(
                  esod_matter_id: @esod_matter.id,  
                  sprawa: @esod_matter.nrid,   
                  dokument: nil,   
                  sygnatura: nil,
                  initialized_from_esod: false,
                  netpar_user: current_user.id)

          #@esod_outgoing_letter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :create, user: current_user, parameters: @esod_matter.attributes.to_json)
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

    def esod_outgoing_letter_params
      params.require(:esod_outgoing_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :wysylka, :identyfikator_adresu, :identyfikator_sposobu_wysylki, 
      :identyfikator_rodzaju_dokumentu_wychodzacego, :data_pisma, :numer_wersji, :uwagi, :zakoncz_sprawe, :zaakceptuj_dokument, 
      :data_utworzenia, :identyfikator_osoby_tworzacej, :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :initialized_from_esod, :netpar_user)
    end


end
