class ProposalsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:show_charts, :index, :datatables_index, :datatables_index_exam]

  before_action :set_proposal, only: [:show, :edit, :edit_approved, :edit_not_approved, :edit_closed, :edit_change_exam, 
                                      :update, :update_approved, :update_not_approved, :update_closed, :update_change_exam, 
                                      :unlock_testportal_tests_access, :lock_testportal_tests_access]

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

  # GET /proposals/1/edit_not_approved
  def edit_closed
    proposal_authorize(@proposal, "edit_closed", params[:category_service])
 
    respond_to do |format|
      format.html { render :edit_closed, locals: { back_url: params[:back_url] } }
    end
  end

  # GET /proposals/1/edit_not_approved
  def edit_change_exam
    proposal_authorize(@proposal, "edit_change_exam", params[:category_service])
 
    respond_to do |format|
      format.html { render :edit_change_exam, locals: { back_url: params[:back_url] } }
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

    unless @proposal.exam.all_exams_divisions_subjects_has_testportal_id
      flash_message :error, t('activerecord.messages.error.has_empty_testportal_id', data: @proposal.exam.fullname)
      respond_to do |format|
        format.html { render :edit_approved, locals: { back_url: params[:back_url] } }
      end
    else
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

  def update_closed
    proposal_authorize(@proposal, "update_closed", params[:category_service])

    @proposal.user_id = current_user.id
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_CLOSED

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_closed_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :closed, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        @proposal.examination.destroy unless @proposal.examination.nil?

        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
      else
        format.html { render :edit_closed, locals: { back_url: params[:back_url] } }
      end
    end
  end

  def update_change_exam
    proposal_authorize(@proposal, "update_change_exam", params[:category_service])

    @proposal.user_id = current_user.id
    if params[:proposal][:exam_id].present? 
      if params[:proposal][:exam_id] != @proposal.exam_id
        exam = Exam.find(params[:proposal][:exam_id])
        @proposal.exam_fullname = exam.fullname
        @proposal.exam_date_exam = exam.date_exam
      end
    end

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_change_exam_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :change_exam, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))
        # najbezpieczniej usunąć stary examination gdyż może zawierać klucze do testportalu
        @proposal.examination.destroy if @proposal.examination.present?
        @proposal.add_to_examinations 

        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
      else
        format.html { render :edit_change_exam, locals: { back_url: params[:back_url] } }
      end
    end
  end

  def unlock_testportal_tests_access
    proposal_authorize(@proposal, "unlock_testportal_tests_access", params[:category_service])

    params[:proposal] ||= {}
    params[:proposal][:user_id] ||= current_user.id
    params[:proposal][:test_unlocked] ||= true

    @proposal.user_id = current_user.id
    @proposal.test_unlocked = true

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_test_locked_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :test_unlocked, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to examination_path(@proposal.examination, category_service: params[:category_service]) }
      end
    end
  end

  def lock_testportal_tests_access
    proposal_authorize(@proposal, "lock_testportal_tests_access", params[:category_service])
    
    params[:proposal] ||= {}
    params[:proposal][:user_id] ||= current_user.id
    params[:proposal][:test_unlocked] ||= false

    @proposal.user_id = current_user.id
    @proposal.test_unlocked = false

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_test_locked_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :test_locked, user: current_user, 
          parameters: @proposal.to_json(except: {proposal: [:id, :proposal_status_id, :user_id]}, 
                  include: { 
                    exam: {
                      only: [:id, :number, :date_exam, :place_exam] },
                    proposal_status: {
                      only: [:id, :name] },
                    user: {
                      only: [:id, :name, :email] } 
                          }))

        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to examination_path(@proposal.examination, category_service: params[:category_service]) }
      end
    end
    
  end

  private
    def proposal_authorize(model_class, action, category_service)
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
      params.require(:proposal).permit(:proposal_status_id, :user_id, :customer_id)
    end
    def proposal_not_approved_params
      params.require(:proposal).permit(:proposal_status_id, :not_approved_comment, :user_id)
    end
    def proposal_closed_params
      params.require(:proposal).permit(:proposal_status_id, :not_approved_comment, :user_id)
    end
    def proposal_change_exam_params
      params.require(:proposal).permit(:exam_id, :exam_fullname, :exam_date_exam, :not_approved_comment, :user_id)
    end
    def proposal_test_locked_params
      params.require(:proposal).permit(:test_unlocked, :user_id)
    end
end
