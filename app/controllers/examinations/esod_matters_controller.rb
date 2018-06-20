class Examinations::EsodMattersController < EsodMattersController
  before_action :set_matterable

  private

    def set_matterable
      @matterable = Examination.find(params[:examination_id])
    end

end