class ProposalsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:show_charts, :index, :datatables_index, :datatables_index_exam, :approved]

  before_action :set_proposal, only: [:show, :edit, :edit_approved, :edit_not_approved, :update, :update_approved, :update_not_approved]

  # def show_charts
  #   respond_to do |format|
  #     format.html{ render :show_charts }
  #   end
  # end

  # GET /proposals
  # GET /proposals.json
  def index
    proposal_authorize(:proposal, "index", params[:category_service])
    # dane pobierane z datatables_index
    # @proposals = Proposal.all
  end

  def datatables_index
    respond_to do |format|
      #format.json{ render json: ProposalDatatable.new(view_context, {category_scope: params[:category] }) }
      format.json{ render json: ProposalDatatable.new(view_context) }
    end
  end

  def datatables_index_exam
    respond_to do |format|
      format.json{ render json: ExamProposalsDatatable.new(view_context, { only_for_current_exam_id: params[:exam_id] }) }
    end
  end

  def select2_index
    params[:q] = params[:q]
    @proposals = Proposal.order(:number).finder_proposal(params[:q], (params[:category_service]).upcase)
    @proposals_on_page = @proposals.page(params[:page]).per(params[:page_limit])

    respond_to do |format|
      format.html
      format.json { 
        render json: @proposals_on_page, each_serializer: ProposalSerializer, meta: {total_count: @proposals.count}
      } 
    end
  end

  # GET /proposals/1
  # GET /proposals/1.json
  def show
    proposal_authorize(@proposal, "show", params[:category_service])

    respond_to do |format|
      format.html { render :show, locals: { back_url: params[:back_url]} }
      format.json { render json: @proposal, root: false, include: [] }
    end
  end

  # GET /proposals/1/edit
  def edit # as not approved
    proposal_authorize(@proposal, "edit", params[:category_service])
 
    respond_to do |format|
      format.json
      format.html { render :edit, locals: { back_url: params[:back_url] } }
    end
  end

  # GET /proposals/1/edit_approved
  def edit_approved
    proposal_authorize(@proposal, "edit_approved", params[:category_service])

    # jesli jest nierozpatrzone elektroniczne zgloszenie z takimi parametrami
    finded_examination = @proposal.is_in_examinations

    if finded_examination.present?
      flash_message :error, t('activerecord.messages.error.is_in_examinations', data: @proposal.fullname)
      redirect_to examination_path(finded_examination.category.downcase, finded_examination)
    else
      respond_to do |format|
        format.html { render :edit_approved, locals: { back_url: params[:back_url] } }
      end
    end
  end

  # GET /proposals/1/edit_not_approved
  def edit_not_approved
    proposal_authorize(@proposal, "edit_not_approved", params[:category_service])
 
    respond_to do |format|
      format.html { render :edit_not_approved, locals: { back_url: params[:back_url] } }
    end
  end

  # PATCH/PUT /proposals/1
  # PATCH/PUT /proposals/1.json
  def update
    proposal_authorize(@proposal, "update", params[:category_service])

    @proposal.user = current_user
 
    respond_to do |format|
      if @proposal.update(proposal_params)
        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
        format.json { render :show, status: :ok, location: @proposal }
      else
        format.html { render :edit, locals: { back_url: params[:back_url] } }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /proposals/1
  def update_approved
    proposal_authorize(@proposal, "update_approved", params[:category_service])

    @proposal.user = current_user
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_APPROVED
 
    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_approved_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :approved, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        @proposal.add_to_examinations

        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
      else
        format.html { render :edit_approved, locals: { back_url: params[:back_url] } }
      end
    end
  end

  # PATCH/PUT /proposals/1
  def update_not_approved
    proposal_authorize(@proposal, "update_not_approved", params[:category_service])

    @proposal.user_id = current_user.id
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_NOT_APPROVED

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_not_approved_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :reject, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        # @examination.works.create!(trackable_url: "#{examination_path(@examination, category_service: params[:category_service])}", action: :update, user: current_user, 
        #   parameters: {examination: @examination.previous_changes, grades: h_grades}.to_json)


        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
      else
        format.html { render :edit_not_approved, locals: { back_url: params[:back_url] } }
      end
    end
  end

  private
    def proposal_authorize(model_class, action, category_service)
      unless ['l', 'm', 'r'].include?(category_service)
         raise "Ruby injection"
      end
      unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work', 
              'edit_approved', 'edit_not_approved', 'update_approved', 'update_not_approved'].include?(action)
         raise "Ruby injection"
      end
      authorize model_class,"#{action}_#{category_service}?"      
    end

    def set_proposal
      params[:id] = params[:proposal_id] if params[:proposal_id].present?
      @proposal = Proposal.find(params[:id])
    end

    def load_exam
      Exam.find(params[:exam_id]) if (params[:exam_id]).present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:esod_category, :customer_id, :category, :note, :user_id)
    end
    def proposal_approved_params
      params.require(:proposal).permit(:proposa_status_id, :user_id, :customer_id)
    end
    def proposal_not_approved_params
      params.require(:proposal).permit(:proposa_status_id, :not_approved_comment, :user_id)
    end
end
