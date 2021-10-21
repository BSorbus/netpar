class DivisionsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index]

  before_action :set_division, only: [:show, :edit, :update, :destroy]

  # GET /divisions
  # GET /divisions.json
  def index
    @divisions = Division.order(:id).all
    authorize :division, :index?
  end

  # GET /divisions/1
  # GET /divisions/1.json
  def show
    authorize @division, :show?
    # przepych
    # @division.works.create!(trackable_url: "#{division_path(@division)}", action: :show, user: current_user, parameters: {})
  end

  # GET /divisions/new
  def new
    @division = Division.new
    authorize :division, :new?
  end

  # GET /divisions/1/edit
  def edit
    authorize @division, :edit?
  end

  # POST /divisions
  # POST /divisions.json
  def create
    @division = Division.new(division_params)
    authorize @division, :create?

    respond_to do |format|
      if @division.save
        # @division.works.create!(trackable_url: "#{division_path(@division)}", action: :create, user: current_user, 
        #   parameters: @division.attributes.to_json)

        flash_message :success, t('activerecord.messages.successfull.created', data: @division.short_name)
        format.html { redirect_to @division }
        format.json { render :show, status: :created, location: @division }
      else
        format.html { render :new }
        format.json { render json: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /divisions/1
  # PATCH/PUT /divisions/1.json
  def update
    authorize @division, :update?
    
    respond_to do |format|
      if @division.update(division_params)
        # @division.works.create!(trackable_url: "#{division_path(@division)}", action: :update, user: current_user, 
        #   parameters: @division.previous_changes.to_json)

        flash_message :success, t('activerecord.messages.successfull.updated', data: @division.short_name)
        format.html { redirect_to @division }
        format.json { render :show, status: :ok, location: @division }
      else
        format.html { render :edit }
        format.json { render json: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /divisions/1
  # DELETE /divisions/1.json
  def destroy
    authorize @division, :destroy?

    if @division.destroy
      Work.create!(trackable: @division, action: :destroy, user: current_user, 
        parameters: @division.attributes.to_json)
 
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @division.short_name)
      redirect_to divisions_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @division.short_name)
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_division
      @division = Division.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def division_params
      params.require(:division).permit(:short_name, :category, :number_prefix, :name, :english_name, :min_years_old, :face_image_required, 
        :for_new_certificate, :proposal_via_internet, subjects_attributes: [:id, :item, :name, :esod_categories, :test_template, :_destroy])
    end
end
