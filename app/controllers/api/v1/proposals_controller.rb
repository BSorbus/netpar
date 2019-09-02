class Api::V1::ProposalsController < Api::V1::BaseApiController

  respond_to :json

  def index
    if params[:creator_id].blank?
      proposals = Proposal.all
    else
      proposals = Proposal.where(creator_id: params[:creator_id])
    end

    render json: proposals, status: :ok, root: true
  end

  def show
    proposal = Proposal.find_by(id: params[:id])
    if proposal.present?
      render json: proposal, status: :ok, root: false
    else
      render json: { error: "Brak rekordu dla Proposal.where(id: #{params[:id]})" }, status: :not_found
    end
  end

  def create
    params[:proposal] = JSON.parse params[:proposal].gsub('=>', ':')
    proposal = Proposal.new(proposal_params)
    if proposal.save
      render json: proposal, status: :created
    else
      render json: { errors: proposal.errors }, status: :unprocessable_entity
    end
  end

  def update
    params[:proposal] = JSON.parse params[:proposal].gsub('=>', ':')
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      if proposal.update(proposal_params)
        render json: proposal, status: :ok
      else
        render json: { errors: proposal.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "Brak rekordu dla Proposal.where(multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end

  def destroy
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      if proposal.destroy
        head :no_content
      else
        render json: { errors: proposal.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "Brak rekordu dla Proposal.where(multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:multi_app_identifier, :proposal_status_id, :category, :creator_id, :user_id, 
        :name, :given_names, :pesel, :birth_date, :birth_place, :phone, :email,
        :address_city, :address_street, :address_house, :address_number, :address_postal_code,
        :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
        :esod_category, :exam_id, :exam_fullname, :date_exam, :division_id, :division_fullname, 
        :exam_fee_id, :exam_fee_price, :face_image_blob_path, :bank_pdf_blob_path )
    end

end
