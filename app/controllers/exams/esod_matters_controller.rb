class Exams::EsodMattersController < EsodMattersController
  before_action :set_matterable

  private

    def set_matterable
      @matterable = Exam.find(params[:exam_id])
    end

end