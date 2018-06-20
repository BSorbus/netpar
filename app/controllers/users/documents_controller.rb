class Users::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = User.find(params[:user_id])
    end

end