require 'esodes'

class Esod::MattersController < ApplicationController
  before_action :authenticate_user!
  #after_action :verify_authorized, except: [:index, :datatables_index]

  before_action :set_esod_matter, only: [:show, :edit, :update, :destroy]

  # GET /esod/matters
  # GET /esod/matters.json 
  def index
#    responseToken = Esod::Token.new(current_user.email, current_user.esod_encryped_password)
#    if responseToken.response_data.present?
#      @stanowiska = responseToken.stanowiska
#      params[:stanowisko_id] = @stanowiska.first[:nrid] unless params[:stanowisko_id].present?
#    else
#      flash[:danger] = "Błąd wywołania funkcji ESOD! --- HTTP CODE: #{responseToken.response_error_http_code} , --- ERROR FAULT CODE: #{responseToken.response_error_faultcode}"
#      flash[:a] = "--- ERROR FAULT STRING: #{responseToken.response_error_faultstring}"
#      flash[:b] = "--- ERROR FAULT DETAIL: #{responseToken.response_error_faultdetail}"
#      redirect_to :back#, alert: t('flash.actions.esod.alert', data: errors )
#    end
#  @stanowiska = [nrid: '12', imie: 'Bogdan', nazwisko: 'jarzab', nazwa: 'boss']
  end

  def datatables_index
    respond_to do |format|
      #format.json{ render json: Esod::MatterDatatable.new(view_context) }
      format.json{ render json: Esod::MatterDatatable.new(view_context, { only_for_stanowisko_id: params[:stanowisko_id], esod_category: params[:esod_category], open: params[:open] }) }
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
    aaa
    @esod_matter = Esod::Matter.new(esod_matter_params)

    respond_to do |format|
      if @esod_matter.save
#        Certificate.find_by(id: params[:certificate_id]).update_columns(esod_matter_id: @esod_matter.id) if params[:certificate_id].present? 
#        Examination.find_by(id: params[:examination_id]).update_columns(esod_matter_id: @esod_matter.id) if params[:examination_id].present? 
#        Exam.find_by(id: params[:exam_id]).update_columns(esod_matter_id: @esod_matter.id) if params[:exam_id].present? 
        format.html { redirect_to params[:back_url], notice: t('activerecord.messages.successfull.created', data: @esod_matter.znak) }
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
      params.require(:esod_matter).permit(:nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod)
    end
end
