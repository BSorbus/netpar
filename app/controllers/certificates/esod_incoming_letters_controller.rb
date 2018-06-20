class Certificates::EsodIncomingLettersController < EsodIncomingLettersController
  before_action :set_incoming_letterable

  private

    def set_incoming_letterable
      @incoming_letterable = Certificate.find(params[:certificate_id])
    end

end