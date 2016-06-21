class EsodOutgoingLettersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_esod_user_id

  def create
    authorize :esod, :show?
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
        if @esod_outgoing_letter.push_soap_and_save(@esod_matter)

          @esod_outgoing_letter.works.create!(trackable_url: "#{esod_matter_outgoing_letter_path(@esod_matter, @esod_outgoing_letter)}", action: :create, user: current_user, parameters: @esod_outgoing_letter.attributes.to_json)
          #flash_message :success, t('activerecord.messages.successfull.created', data: elm.sygnatura)

          flash_message :success, t('activerecord.messages.successfull.created', data: @esod_outgoing_letter.fullname)
          format.html { redirect_to :back }
        else
          #format.html { render :show, alert: t('activerecord.messages.error.created') }
          flash_message :error, t('activerecord.messages.error.created')
          @esod_outgoing_letter.errors.full_messages.each do |msg|
            flash_message :error, msg
          end 
          format.html { redirect_to :back }
        end
      end
    end
  end

  private

    # For cooperation with ESOD
    def set_esod_user_id
      Esodes::EsodTokenData.new(current_user.id)
    end

    def esod_outgoing_letter_params
      params.require(:esod_outgoing_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :identyfikator_adresu, :identyfikator_sposobu_wysylki, 
      :identyfikator_rodzaju_dokumentu_wychodzacego, :data_pisma, :numer_wersji, :uwagi, :zakoncz_sprawe, :zaakceptuj_dokument, 
      :data_utworzenia, :identyfikator_osoby_tworzacej, :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :initialized_from_esod, :netpar_user)
    end


end
