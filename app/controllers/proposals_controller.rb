class ProposalsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:show_charts, :index, :datatables_index, :datatables_index_exam, :approved]

  before_action :set_proposal, only: [:show, :edit, :edit_approved, :edit_not_approved, :update, :update_approved, :update_not_approved, :proposal_to_pdf]

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

  def proposal_card_to_pdf
    proposal_authorize(:proposal, "print", params[:category_service])

    # where(id: param[:id]) czyli pojedynczy rekord @proposals_all -> @proposal ale jako lista 
    #@proposal = Proposal.joins(:customer).references(:customer).where(id: params[:id]).all
    @proposals = Proposal.where(id: params[:id]).all

    if @proposals.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      respond_to do |format|
        format.pdf do
          case params[:category_service]
          when 'l'
            pdf = PdfProposalCardsL.new(@proposals, @proposals.first.exam, view_context)
          when 'm'
            pdf = PdfProposalCardsM.new(@proposals, @proposals.first.exam, view_context)
          when 'r'
            pdf = PdfProposalCardsR.new(@proposals, @proposals.first.exam, view_context)
          end    
          #pdf = PdfCertificatesL.new(@certificates_all, view_context)
          send_data pdf.render,
          filename: "Proposal_Card_#{params[:category_service]}_#{@proposals.first.name}_#{@proposals.first.given_names}_#{@proposals.first.exam_fullname}.pdf",
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @proposals.first.works.create!(trackable_url: "#{proposal_path(@proposals, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: 'proposal_card', filename: "Proposal_Card_#{params[:category_service]}_#{@proposals.first.name}_#{@proposals.first.given_names}_#{@proposals.first.exam_fullname}.pdf"}.to_json)

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
    proposal_authorize(@proposal, "edit", params[:category_service])
 
    respond_to do |format|
      format.html { render :edit_approved, locals: { back_url: params[:back_url] } }
    end
  end

  # GET /proposals/1/edit_not_approved
  def edit_not_approved
    proposal_authorize(@proposal, "edit", params[:category_service])
 
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
    proposal_authorize(@proposal, "update", params[:category_service])

    @proposal.user = current_user
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_APPROVED
 
    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_approved_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :update, user: current_user, 
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

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
      else
        format.html { render :edit_approved, locals: { back_url: params[:back_url] } }
      end
    end
  end

  # PATCH/PUT /proposals/1
  def update_not_approved
    proposal_authorize(@proposal, "update", params[:category_service])

    @proposal.user_id = current_user.id
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_NOT_APPROVED

    respond_to do |format|
      if @proposal.update_rec_and_push(proposal_not_approved_params)
        @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :update, user: current_user, 
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
    def proposal_authorize(model_class, action, category)
      unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work'].include?(action)
         raise "Ruby injection"
      end
      unless ['l', 'm', 'r'].include?(category)
         raise "Ruby injection"
      end
      authorize model_class,"#{action}_#{category}?"      
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
      params.require(:proposal).permit(:proposa_status_id, :user_id)
    end
    def proposal_not_approved_params
      params.require(:proposal).permit(:proposa_status_id, :not_approved_comment, :user_id)
    end
end
