class Certificates::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Certificate.find(params[:certificate_id])
    end

end