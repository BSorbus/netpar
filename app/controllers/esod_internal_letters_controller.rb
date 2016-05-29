class EsodInternalLettersController < ApplicationController
  before_action :authenticate_user!

  def create
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
        if @esod_internal_letter.save

          elm = @esod_internal_letter.esod_internal_letters_matters.create(
                  esod_matter_id: @esod_matter.id,  
                  sprawa: @esod_matter.nrid,   
                  dokument: nil,   
                  sygnatura: nil,
                  initialized_from_esod: false,
                  netpar_user: current_user.id)

          #@esod_internal_letter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :create, user: current_user, parameters: @esod_matter.attributes.to_json)
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

    def esod_internal_letter_params
      params.require(:esod_internal_letter).permit(:nrid, :numer_ewidencyjny, :tytul, :uwagi, :identyfikator_rodzaju_dokumentu_wewnetrznego, 
        :identyfikator_typu_dcmd, :identyfikator_dostepnosci_dokumentu, :pelna_wersja_cyfrowa, :data_utworzenia, :identyfikator_osoby_tworzacej, 
        :data_modyfikacji, :identyfikator_osoby_modyfikujacej, :initialized_from_esod, :netpar_user)
    end


end