class Certificates::EsodMattersController < EsodMattersController
  before_action :set_matterable

  private

    def set_matterable
      @matterable = Certificate.find(params[:certificate_id])
    end

end