class EsodIncomingLettersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_esod_user_id

  def create
    authorize :esod, :show?
    if @incoming_letterable.esod_matters.empty?
      respond_to do |format|
        format.html { redirect_to :back, alert: "Nie ma spraw! Pismo jest tworzone do ostatniej sprawy" }
      end
    else
      @esod_matter = @incoming_letterable.esod_matters.last

      @esod_incoming_letter = @incoming_letterable.esod_matters.last.esod_incoming_letters.new(esod_incoming_letter_params)
      @esod_incoming_letter.initialized_from_esod = false
      @esod_incoming_letter.netpar_user = current_user.id

      # wywolaj funkcje zapisujaca contractora i address do ESODA
      @incoming_letterable.customer.check_and_push_data_to_esod(push_user: current_user.id)

      if @incoming_letterable.customer.errors.present? 
        @incoming_letterable.customer.errors.full_messages.each do |msg|
          flash_message :error, msg
        end 
        redirect_to :back
      else 
        @esod_incoming_letter.identyfikator_osoby = @incoming_letterable.customer.esod_contractor.nrid
        @esod_incoming_letter.identyfikator_adresu = @incoming_letterable.customer.esod_address.nrid
        @esod_incoming_letter.esod_contractor_id = @incoming_letterable.customer.esod_contractor.id
        @esod_incoming_letter.esod_address_id = @incoming_letterable.customer.esod_address.id

        respond_to do |format|
          if @esod_incoming_letter.push_soap_and_save(@esod_matter)           
            @esod_incoming_letter.works.create!(trackable_url: "#{esod_matter_incoming_letter_path(@esod_matter, @esod_incoming_letter)}", action: :create, user: current_user, parameters: @esod_incoming_letter.attributes.to_json)
            #flash_message :success, t('activerecord.messages.successfull.created', data: elm.sygnatura)

            flash_message :success, t('activerecord.messages.successfull.created', data: @esod_incoming_letter.fullname)
            format.html { redirect_to :back }
          else
            #format.html { render :show, alert: t('activerecord.messages.error.created') }
            flash_message :error, t('activerecord.messages.error.created')
            @esod_incoming_letter.errors.full_messages.each do |msg|
              flash_message :error, msg
            end 
            format.html { redirect_to :back }
          end
        end
      end
    end
  end

  private

    # For cooperation with ESOD
    def set_esod_user_id
      Esodes::EsodTokenData.new(current_user.id)
    end

    def esod_incoming_letter_params
      params.require(:esod_incoming_letter).permit( :nrid, :numer_ewidencyjny, :tytul, :data_pisma, :data_nadania, :data_wplyniecia, :znak_pisma_wplywajacego, 
        :identyfikator_typu_dcmd, :identyfikator_rodzaju_dokumentu, :identyfikator_sposobu_przeslania, :identyfikator_miejsca_przechowywania, :termin_na_odpowiedz,
      :pelna_wersja_cyfrowa, :naturalny_elektroniczny, :liczba_zalacznikow, :zgoda, :tajemnica, :uwagi, :identyfikator_osoby, :identyfikator_adresu, 
      :data_utworzenia, :identyfikator_osoby_tworzacej, 
      :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :esod_contractor, :esod_address, :initialized_from_esod, :netpar_user )
    end

end