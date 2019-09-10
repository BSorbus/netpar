class Api::V1::DivisionsController < Api::V1::BaseApiController

  respond_to :json

  def index
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    params[:category] = params[:category]

    @divisions = Division.only_not_exclude.order(:name).finder_division(params[:q], params[:category])
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

end
