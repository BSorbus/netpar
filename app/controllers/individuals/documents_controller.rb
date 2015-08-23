class Individuals::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Individual.find(params[:individual_id])
    end

end