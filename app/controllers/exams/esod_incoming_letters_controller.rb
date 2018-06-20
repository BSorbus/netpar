class Exams::EsodIncomingLettersController < EsodIncomingLettersController
  before_action :set_incoming_letterable

  private

    def set_incoming_letterable
      @incoming_letterable = Exam.find(params[:exam_id])
    end

end