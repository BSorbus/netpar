class ProposalsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:show_charts, :index, :datatables_index, :datatables_index_exam, :approved]

  before_action :set_proposal, only: [:show, :edit, :update, :proposal_to_pdf]

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


  def proposal_to_pdf
    proposal_authorize(:proposal, "print", params[:category_service])

    @proposals_all = Proposal.joins(:customer).references(:customer).where(id: params[:id]).all

    if @proposals_all.empty?
      redirect_to :back, alert: t('activerecord.messages.notice.no_records') and return
    else
      documentname = "Proposal_#{params[:category_service]}_#{@proposals_all.first.number}.pdf"
      author = "#{current_user.name} (#{current_user.email})"

      respond_to do |format|
        format.pdf do
          case params[:category_service]
          when 'l'
            pdf = PdfProposalsL.new(@proposals_all, view_context, author, documentname)
          when 'm'
            pdf = PdfProposalsM.new(@proposals_all, view_context, author, documentname)
          when 'r'
            pdf = PdfProposalsR.new(@proposals_all, view_context, author, documentname)
          end    
          #pdf = PdfProposalsL.new(@proposals_all, view_context)
          send_data pdf.render,
          filename: documentname,
          type: "application/pdf",
          disposition: "inline"   
        end
      end
      @proposal.works.create!(trackable_url: "#{proposal_path(@proposal, category_service: params[:category_service])}", action: :to_pdf, user: current_user, 
                        parameters: {pdf_type: "proposal", filename: "#{documentname}"}.to_json)

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

  # PATCH/PUT /proposals/1
  def approved
    puts '-----------------------APPROVED-------------------------------'
    redirect_to proposals_path(@proposal, category_service: params[:category_service])    
  end

  # GET /proposals/1/edit
  def edit # as not approved
    proposal_authorize(@proposal, "edit", params[:category_service])
 
    respond_to do |format|
      format.json
      format.html { render :edit, locals: { back_url: params[:back_url] } }
    end
  end

  # PATCH/PUT /proposals/1
  # PATCH/PUT /proposals/1.json
  def update
    @proposal.user = current_user
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_NOT_APPROVED
 
    proposal_authorize(@proposal, "update", params[:category_service])

    respond_to do |format|
      if @proposal.update(proposal_not_approved_params)
        flash_message :success, t('activerecord.messages.successfull.updated', data: @proposal.fullname)

        format.html { redirect_to proposal_path(@proposal, category_service: params[:category_service]) }
        format.json { render :show, status: :ok, location: @proposal }
      else
        format.html { render :edit, locals: { back_url: params[:back_url] } }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
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
    def proposal_not_approved_params
      params.require(:proposal).permit(:proposa_status_id, :not_approved_comment, :user_id)
    end
end
