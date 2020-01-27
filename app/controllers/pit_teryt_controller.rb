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

  def items
    items_obj = PitTerytItem.new(q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    if items_obj.request_for_collection # return true
      render json: JSON.parse(items_obj.response.body), status: items_obj.response.code
    else
      if items_obj.response.present?
         render json: { error: items_obj.response.message }, status: items_obj.response.code 
      else 
         render json: { error: items_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def item_show
    item_obj = PitTerytItem.new(id: params[:id])
    if item_obj.request_for_one_row
      render json: JSON.parse(item_obj.response.body), status: item_obj.response.code
    else
      if item_obj.response.present?
         render json: { error: item_obj.response.message }, status: item_obj.response.code 
      else 
         render json: { error: item_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end


end
