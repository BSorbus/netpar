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
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (id: #{params[:id]})" }, status: :not_found
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
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
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
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end

  def grades
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      if proposal.examination.present?
        render status: :ok, json: proposal.examination.grades.order(:id), root: "grades", 
          meta: { total_count: proposal.examination.grades.count,
                  multi_app_identifier: params[:multi_app_identifier]}
      else
        render json: { error: "Elektroniczne Zgłoszenie (multi_app_identifier: #{params[:multi_app_identifier]}) nie zostało jeszcze zaakceptowane w systemie Netpar2015" }, status: :not_found
      end
    else
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end

  def grades_with_result
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      if proposal.examination.present?
        grades = proposal.examination.grades #.where(grade_result: 'N').order(:id) 
        render status: :ok, json: grades, each_serializer: Api::V1::GradeWithResultSerializer, root: "grades_with_result", meta: {total_count: grades.count, multi_app_identifier: params[:multi_app_identifier]}
      else
        render json: { error: "Elektroniczne Zgłoszenie (multi_app_identifier: #{params[:multi_app_identifier]}) nie zostało jeszcze zaakceptowane w systemie Netpar2015" }, status: :not_found
      end
    else
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:multi_app_identifier, :proposal_status_id, :category, :creator_id, 
        :name, :given_names, :pesel, :citizenship_code, :birth_date, :birth_place, :family_name, :phone, :email,
        :lives_in_poland, :address_combine_id, :province_code, :province_name, :district_code, :district_name,
        :commune_code, :commune_name, :city_code, :city_name, :city_parent_code, :city_parent_name, :street_code, :street_name, :street_attribute,
        :c_address_house, :c_address_number, :c_address_postal_code,
        :esod_category, :exam_id, :exam_fullname, :exam_date_exam, :exam_online, :division_id, :division_fullname, :division_short_name, :division_min_years_old, 
        :exam_fee_id, :exam_fee_price, :face_image_blob_path, :bank_pdf_blob_path, :consent_pdf_blob_path, :other_pdf_blob_path, :test_unlocked )
    end

end
