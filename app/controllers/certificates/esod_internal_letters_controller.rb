class Certificates::EsodInternalLettersController < EsodInternalLettersController
  before_action :set_internal_letterable

  private

    def set_internal_letterable
      @internal_letterable = Certificate.find(params[:certificate_id])
    end

end