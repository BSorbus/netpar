class Api::V1::DivisionsController < Api::V1::BaseApiController

  respond_to :json

  def index
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    params[:category] = category_params_validate(params[:category])

    @divisions = Division.only_not_exclude_for_internet.order(:name).finder_division(params[:q], params[:category])
    @divisions_on_page = @divisions.page(params[:page]).per(params[:page_limit])

    render status: :ok,
           json: @divisions_on_page, meta: {total_count: @divisions.count}
  end

  def show
    #authorize :exam, :show?
    division = Division.find_by(id: params[:id])
    if division.present?
      render status: :ok, json: division, root: false
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla Division.where(id: #{params[:id]})" }
    end
  end

  private
    def category_params_validate(category_service)
      unless ['l', 'm', 'r', 'L', 'M', 'R', '', nil].include?(category_service)
        raise "Ruby injection"
      end
      return category_service
    end
end
