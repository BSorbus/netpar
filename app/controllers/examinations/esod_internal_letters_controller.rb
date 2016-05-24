class Examinations::EsodInternalLettersController < EsodInternalLettersController
  before_action :set_internal_letterable

  private

    def set_internal_letterable
      @internal_letterable = Examination.find(params[:examination_id])
    end

end