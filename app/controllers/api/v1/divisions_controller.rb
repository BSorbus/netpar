class Api::V1::DivisionsController < Api::V1::BaseApiController

  respond_to :json

  # GET /divisions
  #   enabled_in_confirmation=true – rodzaje do weryfikacji w Confirmation (divisions.enabled_in_confirmation),
  #   enabled_in_examination=true  – rodzaje dla zapisów przez internet w Egzaminach (divisions.proposal_via_internet);
  #     w obu: kategoria opcjonalna (bez niej wszystkie), opcjonalne wyszukiwanie q, wg id,
  #     bez stronicowania (chyba że podano page_limit),
  #   bez tych parametrów – dotychczasowe działanie dla Egzaminów (proposal_via_internet, wymagana kategoria,
  #     wg nazwy, stronicowanie).
  def index
    return index_enabled_in_confirmation if params[:enabled_in_confirmation].to_s == 'true'
    return index_enabled_in_examination if params[:enabled_in_examination].to_s == 'true'

    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    params[:category] = category_params_validate(params[:category])

    @divisions = Division.only_not_exclude_for_internet.order(:name).finder_division(params[:q], params[:category])
    @divisions_on_page = @divisions.page(params[:page]).per(params[:page_limit])

    render status: :ok,
           json: @divisions_on_page, meta: {total_count: @divisions.count}
  end

  # GET /divisions/:id – pełny opis rodzaju (także niewłączonego) z przedmiotami egzaminu.
  def show
    #authorize :exam, :show?
    division = Division.find_by(id: params[:id])
    if division.present?
      render status: :ok, json: division, root: false, serializer: Api::V1::DivisionWithSubjectsSerializer
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla Division.where(id: #{params[:id]})" }
    end
  end

  private
    def index_enabled_in_confirmation
      render_divisions_index(Division.only_enabled_in_confirmation)
    end

    def index_enabled_in_examination
      render_divisions_index(Division.only_not_exclude_for_internet)
    end

    def render_divisions_index(scope)
      category = category_params_validate(params[:category])
      divisions = scope.order(:id)
      divisions = divisions.only_category_scope(category) if category.present?
      divisions = divisions.finder_query(params[:q]) if params[:q].present?
      divisions_on_page = params[:page_limit].present? ? divisions.page(params[:page]).per(params[:page_limit]) : divisions

      render status: :ok,
             json: divisions_on_page, meta: {total_count: divisions.count}
    end

    def category_params_validate(category_service)
      unless ['l', 'm', 'r', 'L', 'M', 'R', '', nil].include?(category_service)
        raise InvalidParameter, "Nieprawidłowa kategoria (dozwolone: L, M, R)"
      end
      return category_service
    end
end
