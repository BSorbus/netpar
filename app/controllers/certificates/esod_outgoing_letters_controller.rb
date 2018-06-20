class Certificates::EsodOutgoingLettersController < EsodOutgoingLettersController
  before_action :set_outgoing_letterable

  private

    def set_outgoing_letterable
      @outgoing_letterable = Certificate.find(params[:certificate_id])
    end

end