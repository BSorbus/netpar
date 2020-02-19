class ChartsController < ApplicationController
  before_action :authenticate_user!


  def certificates_by_month
    result = Certificate.where(category: params[:category_service].upcase).group_by_month(:created_at, last: 60).count
    render json: result
  end

  def certificates_update_by_month
    result = Certificate.where(category: params[:category_service].upcase).group_by_month(:updated_at, last: 60).count
    render json: result
  end

  def certificates_date_of_issue_by_month
    result = Certificate.where(category: params[:category_service].upcase).group_by_month(:date_of_issue, last: 16).count
    render json: result
  end

  def certificates_by_month_division
    # Jest OK
    # result = Certificate.where(category: params[:category_service].upcase).group(:division_id).group_by_month(:created_at, last: 60).count.chart_json
    # render json: result

    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Certificate.where(category: params[:category_service].upcase, division: division).group_by_month(:created_at, last: 12, format: '%Y-%m-%d').count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
  end

  def certificates_update_by_month_division
    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Certificate.where(category: params[:category_service].upcase, division: division).group_by_month(:updated_at, last: 12, format: '%Y-%m-%d').count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
  end

  def certificates_date_of_issu_by_month_division
    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Certificate.where(category: params[:category_service].upcase, division: division).group_by_month(:updated_at, last: 12, format: '%Y-%m-%d').count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
  end

  def confirmation_logs_by_month
    result = ConfirmationLog.group_by_month(:created_at, last: 12).count
    render json: result
  end

  def proposals_by_week_division
    start_date = Date.parse('2020-02-01')
    end_date = Time.zone.today

    total_days = (end_date - start_date).to_i
    total_weeks = ((end_date - start_date) / 7 ).to_f.round

    data_array = []
    Division.only_category_scope(params[:category_service]).all.each do |division|
      data_array << { name: "#{division.short_name}", 
                      data: Proposal.where(category: params[:category_service].upcase, division: division).where.not(proposal_status_id: Proposal::PROPOSAL_STATUS_ANNULLED).group_by_week(:created_at, last: total_weeks, format: '%Y-%m-%d').count.map{|k,v| [k,v]} }
    end
    render json: data_array.to_json 
  end

end