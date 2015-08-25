class Examinations::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Examination.find(params[:examination_id])
    end

end