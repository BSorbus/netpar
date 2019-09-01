class Api::V1::DivisionsController < Api::V1::BaseApiController

  respond_to :json

  def index
    case params[:category]
    when 'L'
      divisions = Division.where(category: params[:category]).order(:name)
    when 'M'
      divisions = Division.where(category: params[:category], id: Division::DIVISION_M_FOR_SHOW).order(:name)
    when 'R'
      divisions = Division.where(category: params[:category], id: Division::DIVISION_R_FOR_SHOW).order(:name)      
    end

    render status: :ok,
           json: divisions, meta: {total_count: divisions.count}
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
