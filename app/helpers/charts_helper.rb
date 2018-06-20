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

end