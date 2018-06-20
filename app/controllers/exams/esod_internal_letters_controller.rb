class Exams::EsodInternalLettersController < EsodInternalLettersController
  before_action :set_internal_letterable

  private

    def set_internal_letterable
      @internal_letterable = Exam.find(params[:exam_id])
    end

end