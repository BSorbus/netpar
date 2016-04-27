require 'esodes'

class Esod::MattersController < ApplicationController
  before_action :authenticate_user!
  #after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_esod_matter, only: [:show, :edit, :update, :destroy]

  # GET /esod/matters
  # GET /esod/matters.json 
  def index
#    @esod_matters = Esod::Matter.all
  #  @token_data = Esod::Token.new(current_user.email, current_user.esod_encryped_password)
#    if @token_data.present?
  #    @stanowiska = @token_data.stanowiska
 
#      @stanowiska = { "stanowisko"=>[ 
#                                      {"id"=>"1", "name"=>"Kowalski"},
#                                      {"id"=>"2", "name"=>"Nowak"}
#                                    ]
#                    }
  
      #@deserialize_stanowisko = ActiveSupport::JSON.decode(@stanowiska.to_json)

#      puts '----------------------------------------'
#      puts @stanowiska
#      puts '----------------------------------------'
#      puts @stanowiska.to_json
#      puts '----------------------------------------'
#      puts JSON.parse(@stanowiska.to_json)
#      puts '----------------------------------------'
#      puts JSON.pretty_generate(JSON.parse(@stanowiska.to_json))
#      puts '----------------------------------------'
#      puts JSON.pretty_generate(@stanowiska)
#      puts '----------------------------------------'
#      puts @deserialize_stanowisko
#      puts '----------------------------------------'
#    end
    @esod_matters = Esod::Matter.all
    #params[:only_sessions] = false unless params[:only_sessions].present?
#    respond_to do |format|
#      format.html 
#      #format.html { render :index, locals: { only_sessions: params[:only_sessions] } }
#    end        
  end

  def datatables_index
    respond_to do |format|
      format.json{ render json: Esod::MatterDatatable.new(view_context) }
    end
  end

  def select2_index 
    params[:q] = params[:q]
    params[:iks] = params[:iks]
    params[:jrwa] = params[:jrwa]
    @esod_matters = Esod::Matter.order(:znak).finder_esod_matter(params[:q], params[:iks], params[:jrwa])
    @esod_matters_on_page = @esod_matters.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { 
        render json: @esod_matters_on_page, each_serializer: Esod::MatterSerializer, meta: {total_count: @esod_matters.count}
      } 
    end
  end


  # GET /esod/matters/1
  # GET /esod/matters/1.json
  def show 
    respond_to do |format|
      format.json { render json: @esod_matter, root: false }
      format.html do

        category_service =
          if    Esodes::JRWA_L.include?(@esod_matter.symbol_jrwa.to_i)
            'l'
          elsif Esodes::JRWA_M.include?(@esod_matter.symbol_jrwa.to_i)
            'm'
          elsif Esodes::JRWA_R.include?(@esod_matter.symbol_jrwa.to_i)
            'r'
          else
            raise "Bad param symbol_jrwa: #{@esod_matter.symbol_jrwa}"
          end

        resource_service =
          if Esodes::ALL_CATEGORIES_EXAMS.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'exam'
          elsif Esodes::ALL_CATEGORIES_EXAMINATIONS.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'examination'
          elsif Esodes::ALL_CATEGORIES_CERTIFICATES.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'certificate'
          else
            #raise "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
            "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
          end

        action_service =
          if Esodes::ACTION_NEW.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'new'
          elsif Esodes::ACTION_EDIT.include?(@esod_matter.identyfikator_kategorii_sprawy)
            'edit'
          else
            #raise "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
            "Bad param identyfikator_kategorii_sprawy: #{@esod_matter.identyfikator_kategorii_sprawy}"
          end

        #@esod_matter.save_to_esod(current_user.email, current_user.esod_encryped_password)
       
        render :show, locals: { category_service: category_service, resource_service: resource_service, action_service: action_service } 
      end
    end    
  end

  # GET /esod/matters/new
  def new
    @esod_matter = Esod::Matter.new
  end

  # GET /esod/matters/1/edit
  def edit
  end

  # POST /esod/matters
  # POST /esod/matters.json
  def create
    @esod_matter = Esod::Matter.new(esod_matter_params)

    respond_to do |format|
      if @esod_matter.save
        format.html { redirect_to @esod_matter, notice: 'Matter was successfully created.' }
        format.json { render :show, status: :created, location: @esod_matter }
      else
        format.html { render :new }
        format.json { render json: @esod_matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /esod/matters/1
  # PATCH/PUT /esod/matters/1.json
  def update
    respond_to do |format|
      if @esod_matter.update(esod_matter_params)
        format.html { redirect_to @esod_matter, notice: 'Matter was successfully updated.' }
        format.json { render :show, status: :ok, location: @esod_matter }
      else
        format.html { render :edit }
        format.json { render json: @esod_matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /esod/matters/1
  # DELETE /esod/matters/1.json
  def destroy
    @esod_matter.destroy
    respond_to do |format|
      format.html { redirect_to esod_matters_url, notice: 'Matter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_esod_matter
      @esod_matter = Esod::Matter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_matter_params
      params.require(:esod_matter).permit(:nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :adnotacja, :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod)
    end
end
