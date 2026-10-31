class Api::V1::ProposalsController < Api::V1::BaseApiController

  ANNULLABLE_STATUSES = [ ProposalStatus::PROPOSAL_STATUS_CREATED, ProposalStatus::PROPOSAL_STATUS_APPROVED ]

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

  # Ponowne wysłanie tego samego zgłoszenia (ten sam multi_app_identifier – np. podwójne kliknięcie albo ponowienie
  # po braku odpowiedzi) nie tworzy duplikatu: zwracamy istniejące zgłoszenie (200). Równoczesne żądania rozstrzyga
  # unikalny indeks (migracja AddUniqueIndexToProposalsMultiAppIdentifier).
  # Nowe zgłoszenie zawsze ze statusem „utworzone” i zablokowanym testem online – status nadaje urzędnik w NETPAR.
  def create
    params[:proposal] = parsed_proposal_param
    existing = existing_proposal(proposal_params[:multi_app_identifier])
    return render(json: existing, status: :ok) if existing

    proposal = Proposal.new(proposal_params.merge(proposal_status_id: ProposalStatus::PROPOSAL_STATUS_CREATED, test_unlocked: false))
    if proposal.save
      render json: proposal, status: :created
    else
      render json: { errors: proposal.errors }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    render json: existing_proposal(proposal_params[:multi_app_identifier]), status: :ok
  rescue JSON::ParserError
    render_invalid_proposal_param
  end

  # Zmiana zgłoszenia przez aplikację Egzaminy. Status przez API można zmienić wyłącznie na „anulowane”
  # (z „utworzone” lub „zaakceptowane” – jak pozwala użytkownikowi aplikacja); odblokowanie testu – tylko w NETPAR.
  def update
    params[:proposal] = parsed_proposal_param
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      attributes = proposal_params.except(:proposal_status_id, :test_unlocked)
      requested_status = proposal_params[:proposal_status_id].presence && proposal_params[:proposal_status_id].to_i
      if requested_status && requested_status != proposal.proposal_status_id
        unless requested_status == ProposalStatus::PROPOSAL_STATUS_ANNULLED && ANNULLABLE_STATUSES.include?(proposal.proposal_status_id)
          return render json: { error: "Przez API można zmienić status zgłoszenia tylko na „anulowane” (ze statusu „utworzone” lub „zaakceptowane”)" }, status: :unprocessable_entity
        end
        attributes[:proposal_status_id] = requested_status
      end
      if proposal.update(attributes)
        render json: proposal, status: :ok
      else
        render json: { errors: proposal.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "W systemie Netpar2015 brak Elektronicznego Zgłoszenia (multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  rescue JSON::ParserError
    render_invalid_proposal_param
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
    # Parametr "proposal": JSON (Egzaminy 8) albo Hash#to_s z Ruby (dotychczasowa aplikacja Egzaminy) –
    # zamiana „=>” na „:” tylko dla starego formatu, żeby nie psuć tekstów zawierających „=>”.
    def parsed_proposal_param
      raw = params[:proposal].to_s
      JSON.parse(raw)
    rescue JSON::ParserError
      JSON.parse(raw.gsub('=>', ':'))
    end

    def render_invalid_proposal_param
      render json: { error: "Niepoprawne dane zgłoszenia (parametr proposal)" }, status: :unprocessable_entity
    end

    def existing_proposal(multi_app_identifier)
      Proposal.where(multi_app_identifier: multi_app_identifier).order(:id).first if multi_app_identifier.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:multi_app_identifier, :proposal_status_id, :category, :creator_id, 
        :name, :given_names, :pesel, :citizenship_code, :birth_date, :birth_place, :family_name, :phone, :email,
        :lives_in_poland, :address_combine_id, :province_code, :province_name, :district_code, :district_name,
        :commune_code, :commune_name, :city_code, :city_name, :city_parent_code, :city_parent_name, :street_code, :street_name, :street_attribute,
        :c_address_house, :c_address_number, :c_address_postal_code,
        :esod_category, :exam_id, :exam_fullname, :exam_date_exam, :exam_online, :division_id, :division_fullname, :division_short_name, :division_min_years_old, :division_face_image_required, 
        :exam_fee_id, :exam_fee_price, :face_image_blob_path, :bank_pdf_blob_path, :consent_pdf_blob_path, :other_pdf_blob_path, :test_unlocked )
    end

end
