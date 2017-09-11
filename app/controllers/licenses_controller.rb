class LicensesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_license, only: [:show]

  # GET /licenses
  # GET /licenses.json
  def index
    authorize :license, :show?
    #@licenses = License.all
  end

  # POST /customers
  def datatables_index
    respond_to do |format|
      format.json{ render json: LicenseDatatable.new(view_context) }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.json
  def show
    authorize :license, :show?
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_license
      @license = License.find(params[:id])
    end
end
