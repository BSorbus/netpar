class ExamFeesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:datatables_index]

  before_action :set_exam_fee, only: [:show, :edit, :update, :destroy]

  # GET /exam_fees
  # GET /exam_fees.json
  def index
    authorize :exam_fee, :index?
  end

  def datatables_index
    exam_fees = ExamFee.includes(:division).all 

    respond_to do |format|
      format.json{ 
        render json: exam_fees, each_serializer: ExamFeeSerializer, root: 'data'
      }
    end
  end

  # GET /exam_fees/1
  # GET /exam_fees/1.json
  def show
    authorize @exam_fee, :show?

    respond_to do |format|
      format.html { render :show, locals: { back_url: params[:back_url]} }
    end
  end

  # GET /exams/new
  def new
    @exam_fee = ExamFee.new 
    @exam_fee.category = '' 
    authorize @exam_fee, :new?
  end

  # GET /exam_fees/1/edit
  def edit 
    authorize @exam_fee, :edit?
  end

  # POST /exam_fees
  # POST /exam_fees.json
  def create
    @exam_fee = ExamFee.new(exam_fee_params)
    authorize @exam_fee, :create?

    respond_to do |format|
      if @exam_fee.save
        @exam_fee.works.create!(trackable_url: "#{exam_fee_path(@exam_fee)}", action: :create, user: current_user, 
          parameters: @exam_fee.attributes.to_json)

        flash_message :success, t('activerecord.messages.successfull.created', data: @exam_fee.fullname)
        format.html { redirect_to @exam_fee }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /exam_fees/1
  # PATCH/PUT /exam_fees/1.json
  def update
    authorize @exam_fee, :update?

    @exam_fee.user = current_user
 
    respond_to do |format|
      if @exam_fee.update(exam_fee_params)
        @exam_fee.works.create!(trackable_url: "#{exam_fee_path(@exam_fee)}", action: :update, user: current_user, 
          parameters: @exam_fee.previous_changes.to_json)

        flash_message :success, t('activerecord.messages.successfull.updated', data: @exam_fee.fullname)

        format.html { redirect_to exam_fee_path(@exam_fee, category_service: params[:category_service]) }
      else
        format.html { render :edit, locals: { back_url: params[:back_url] } }
      end
    end
  end

  # DELETE /divisions/1
  # DELETE /divisions/1.json
  def destroy
    authorize @exam_fee, :destroy?

    if @exam_fee.destroy
      Work.create!(trackable: @exam_fee, action: :destroy, user: current_user, 
        parameters: @exam_fee.attributes.to_json)
 
      flash_message :success, t('activerecord.messages.successfull.destroyed', data: @exam_fee.fullname)
      redirect_to exam_fees_url
    else 
      flash_message :error, t('activerecord.messages.error.destroyed', data: @exam_fee.short_name)
      render :show
    end      
  end

  private
    def exam_fee_authorize(model_class, action, category_service)
      unless ['l', 'm', 'r'].include?(category_service)
         raise "Ruby injection"
      end
      unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work', 
              'edit_approved', 'edit_not_approved', 'edit_closed', 'edit_change_exam', 
              'update_approved', 'update_not_approved', 'update_closed', 'update_change_exam',
              'unlock_testportal_tests_access', 'lock_testportal_tests_access'].include?(action)
         raise "Ruby injection"
      end
      authorize model_class,"#{action}_#{category_service}?"      
    end

    def set_exam_fee
      params[:id] = params[:exam_fee_id] if params[:exam_fee_id].present?
      @exam_fee = ExamFee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exam_fee_params
      params.require(:exam_fee).permit(:division_id, :esod_category, :price, :valid_from, :valid_to)
    end

end
