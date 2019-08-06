class Proposals::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Proposal.find(params[:proposal_id])
    end

end