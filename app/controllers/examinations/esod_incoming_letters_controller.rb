class Examinations::EsodIncomingLettersController < EsodIncomingLettersController
  before_action :set_incoming_letterable

  private

    def set_incoming_letterable
      @incoming_letterable = Examination.find(params[:examination_id])
    end

end