module ChartsHelper

  def chart_certificates_by_month
    line_chart certificates_by_month_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_update_by_month
    line_chart certificates_update_by_month_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_update_by_month
    line_chart certificates_update_by_month_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_date_of_issue_by_month
    line_chart certificates_date_of_issue_by_month_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_by_month_division
    line_chart certificates_by_month_division_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_update_by_month_division
    line_chart certificates_update_by_month_division_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_certificates_date_of_issu_by_month_division      
    line_chart certificates_date_of_issu_by_month_division_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

  def chart_confirmation_logs_by_month
    line_chart confirmation_logs_by_month_charts_path(), adapter: "highcharts"
  end

  def chart_proposals_by_week_division
    line_chart proposals_by_week_division_charts_path(category_service: params[:category_service]), adapter: "highcharts"
  end

end