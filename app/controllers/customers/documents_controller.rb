class Customers::DocumentsController < DocumentsController
  before_action :set_documentable

  private

    def set_documentable
      @documentable = Customer.find(params[:customer_id])
    end

end