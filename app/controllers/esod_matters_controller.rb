class EsodMattersController < ApplicationController
  before_action :authenticate_user!

  def create
    @esod_matter = @matterable.esod_matters.new(esod_matter_params)
    @esod_matter.initialized_from_esod = false
    @esod_matter.netpar_user = current_user.id

    respond_to do |format|
      if @esod_matter.save
        @esod_matter.works.create!(trackable_url: "#{esod_matter_path(@esod_matter)}", action: :create, user: current_user, parameters: @esod_matter.attributes.to_json)

        format.html { redirect_to :back, notice: t('activerecord.messages.successfull.created', data: @esod_matter.znak) }
      else
        #format.html { render :show, alert: t('activerecord.messages.error.created') }
        format.html { redirect_to :back, alert: t('activerecord.messages.error.created') }
      end
    end
  end

  private

    def esod_matter_params
      params.require(:esod_matter).permit(:nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, 
        :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod, :exam_id, :examination_id, 
        :certificate_id, esod_matter_notes_attributes: [:id, :tytul])
    end


end