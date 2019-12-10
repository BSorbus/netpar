require 'net/http'

class PitTerytController < ApplicationController

  def province_show
    provinces_obj = PitTerytProvince.new(id: params[:id])
    provinces_obj.run_request

    render json: provinces_obj.row_data, status: provinces_obj.response.code
  end

  def provinces_select2_index
    provinces_obj = PitTerytProvince.new(q: params[:q])
    provinces_obj.run_request

    render json: params[:q].blank? ? provinces_obj.array_provinces : provinces_obj.array_query_provinces, root: 'provinces',
            meta: {total_count: provinces_obj.array_provinces.size}, status: provinces_obj.response.code
  end

end
