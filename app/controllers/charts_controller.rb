class ChartsController < ApplicationController
  before_action :authenticate_user!


  def by_month_certificates
    result = Certificate.where(category: params[:category_service].upcase).group_by_month(:created_at, last: 60).count
    render json: result
  end

  def by_week_certificates
    result = Certificate.where(category: params[:category_service].upcase).group_by_week(:created_at, last: 16).count
    render json: result
  end

  def by_month_division_certificates
    # Jest OK
    # result = Certificate.where(category: params[:category_service].upcase).group(:division_id).group_by_month(:created_at, last: 60).count.chart_json
    # render json: result

    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Certificate.where(category: params[:category_service].upcase, division: division).group_by_month(:created_at, last: 60, format: '%Y-%m-%d').count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
  end

  def by_week_division_certificates
    # Jest OK
    # result = Certificate.where(category: params[:category_service].upcase).group(:division_id).group_by_week(:created_at, last: 60).count.chart_json
    # render json: result

    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Certificate.where(category: params[:category_service].upcase, division: division).group_by_week(:created_at, last: 16).count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
 end















  def by_month_all_errands
    result1 = Errand.group_by_month(:adoption_date).count
    result2 = Errand.group_by_month(:start_date).count
    result3 = Errand.group_by_month(:end_date).count

    render json: [{name: 'Ilość (wg daty przyjęcia)',   data: result1},
                  {name: 'Ilość (wg daty rozpoczęcia)', data: result2},
                  {name: 'Ilość (wg daty zakończenia)', data: result3}]
  end


end