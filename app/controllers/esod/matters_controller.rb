require 'esodes'

class Esod::MattersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :select2_index]

  before_action :set_esod_matter, only: [:show, :edit, :update, :destroy]
  before_action :set_esod_user_id

  # GET /esod/matters
  # GET /esod/matters.json 
  def index
    authorize :esod, :index?

    Esodes::EsodTokenData.token_string
    if Esodes::EsodTokenData.response_token_errors.present? 
      Esodes::EsodTokenData.response_token_errors.each do |err|
        flash_message :error, "#{err}"
      end

      redirect_to :back    
    end
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
    authorize :esod, :show?

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
    authorize :esod, :new?
    @esod_matter = Esod::Matter.new
  end

  # GET /esod/matters/1/edit
  def edit
    authorize :esod, :edit?
  end

  # POST /esod/matters
  # POST /esod/matters.json
  def create
    authorize :esod, :create?
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
    authorize :esod, :update?
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
    authorize :esod, :destroy?
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

    # For cooperation with ESOD
    def set_esod_user_id
      Esodes::EsodTokenData.new(current_user.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def esod_matter_params
      params.require(:esod_matter).permit(:nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod)
    end
end
