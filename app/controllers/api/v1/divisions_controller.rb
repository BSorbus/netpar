class Api::V1::DivisionsController < Api::V1::BaseApiController

  DIVISION_R_A = 18
  DIVISION_R_B = 19
  DIVISION_R_C = 20
  DIVISION_R_D = 21

  respond_to :json

  def index
    case params[:category]
    when 'L', 'M'
      divisions = Division.where(category: params[:category]).order(:name)
    when 'R'
      divisions = Division.where(category: params[:category]).where.not(id: [DIVISION_R_B, DIVISION_R_D]).order(:name)      
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
