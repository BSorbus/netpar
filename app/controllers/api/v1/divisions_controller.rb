require 'esodes'

class Api::V1::DivisionsController < Api::V1::BaseApiController

  respond_to :json


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

  def lot
    #authorize :exam, :index_l?

    divisions = Division.where(category: "L").order(:name)

    render status: :ok,
           json: divisions, meta: {total_count: divisions.count}

  end

  def mor
    #authorize :exam, :index_l?

    divisions = Division.where(category: "M").order(:name)

    render status: :ok,
           json: divisions, meta: {total_count: divisions.count}

  end

  def ra
    #authorize :exam, :index_l?

    divisions = Division.where(category: "R").order(:name)

    render status: :ok,
           json: divisions, meta: {total_count: divisions.count}

  end



end
