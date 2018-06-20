class Examinations::EsodOutgoingLettersController < EsodOutgoingLettersController
  before_action :set_outgoing_letterable

  private

    def set_outgoing_letterable
      @outgoing_letterable = Examination.find(params[:examination_id])
    end

end