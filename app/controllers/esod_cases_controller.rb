class EsodCasesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_esod_case, only: [:show, :edit, :update, :destroy]

  # GET /esod_cases
  # GET /esod_cases.json
  def index
    @token_data = Token.new(current_user.email, current_user.esod_encryped_password)
    if @token_data.present?
      @stanowiska = @token_data.stanowiska
 
#      @stanowiska = { "stanowisko"=>[ 
#                                      {"id"=>"1", "name"=>"Kowalski"},
#                                      {"id"=>"2", "name"=>"Nowak"}
#                                    ]
#                    }
  
      @deserialize_stanowisko = ActiveSupport::JSON.decode(@stanowiska.to_json)

      puts '----------------------------------------'
      puts @stanowiska
      puts '----------------------------------------'
      puts @stanowiska.to_json
      puts '----------------------------------------'
      puts JSON.parse(@stanowiska.to_json)
      puts '----------------------------------------'
      puts JSON.pretty_generate(JSON.parse(@stanowiska.to_json))
      puts '----------------------------------------'
      puts JSON.pretty_generate(@stanowiska)
      puts '----------------------------------------'
      puts @deserialize_stanowisko
      puts '----------------------------------------'
    end
    @esod_cases = EsodCase.all
  end

  def datatables_index
    respond_to do |format|
      format.json{ render json: EsodCaseDatatable.new(view_context) }
    end
  end

  # GET /esod_cases/1
  # GET /esod_cases/1.json
  def show
  end

  # GET /esod_cases/new
  def new
    @esod_case = EsodCase.new
  end

  # GET /esod_cases/1/edit
  def edit
  end

  # POST /esod_cases
  # POST /esod_cases.json
  def create
    @esod_case = EsodCase.new(esod_case_params)

    respond_to do |format|
      if @esod_case.save
        format.html { redirect_to @esod_case, notice: 'Esod case was successfully created.' }
        format.json { render :show, status: :created, location: @esod_case }
      else
        format.html { render :new }
        format.json { render json: @esod_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod_cases/1
  # PATCH/PUT /esod_cases/1.json
  def update
    respond_to do |format|
      if @esod_case.update(esod_case_params)
        format.html { redirect_to @esod_case, notice: 'Esod case was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_case }
      else
        format.html { render :edit }
        format.json { render json: @esod_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod_cases/1
  # DELETE /esod_cases/1.json
  def destroy
    @esod_case.destroy
    respond_to do |format|
      format.html { redirect_to esod_cases_url, notice: 'Esod case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_case
      @esod_case = EsodCase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_case_params
      params.require(:esod_case).permit(:nrid, :znak, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :adnotacja, :identyfikator_stanowiska_referenta, :czy_otwarta, :esod_created_at, :esod_updated_et)
    end
end
