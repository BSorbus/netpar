class Exams::EsodOutgoingLettersController < EsodOutgoingLettersController
  before_action :set_outgoing_letterable

  private

    def set_outgoing_letterable
      @outgoing_letterable = Exam.find(params[:exam_id])
    end

end