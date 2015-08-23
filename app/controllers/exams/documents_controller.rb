class Exams::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Exam.find(params[:exam_id])
    end

end