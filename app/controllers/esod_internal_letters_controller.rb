class EsodInternalLettersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_esod_user_id

  def create
    authorize :esod, :show?
    if @internal_letterable.esod_matters.empty?
      respond_to do |format|
        format.html { redirect_to :back, alert: "Nie ma spraw! Pismo jest tworzone do ostatniej sprawy" }
      end
    else
      @esod_matter = @internal_letterable.esod_matters.last

      @esod_internal_letter = @internal_letterable.esod_matters.last.esod_internal_letters.new(esod_internal_letter_params)
      @esod_internal_letter.initialized_from_esod = false
      @esod_internal_letter.netpar_user = current_user.id

      respond_to do |format|
        if @esod_internal_letter.push_soap_and_save(@esod_matter)
          @esod_internal_letter.works.create!(trackable_url: "#{esod_matter_internal_letter_path(@esod_matter, @esod_internal_letter)}", action: :create, user: current_user, parameters: @esod_internal_letter.attributes.to_json)

          flash_message :success, t('activerecord.messages.successfull.created', data: @esod_internal_letter.fullname)
          format.html { redirect_to :back }
        else
          #format.html { render :show, alert: t('activerecord.messages.error.created') }
          flash_message :error, t('activerecord.messages.error.created')
          @esod_internal_letter.errors.full_messages.each do |msg|
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

    def esod_internal_letter_params
      params.require(:esod_internal_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :uwagi, :identyfikator_rodzaju_dokumentu_wewnetrznego, 
        :identyfikator_typu_dcmd, :identyfikator_dostepnosci_dokumentu, :pelna_wersja_cyfrowa, :data_utworzenia, :identyfikator_osoby_tworzacej, 
        :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :initialized_from_esod, :netpar_user)
    end


end