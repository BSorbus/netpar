require 'esodes'

class Api::V1::ExamsController < Api::V1::BaseApiController

  respond_to :json


  def index
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    date_exam_min = (Time.zone.today + 14.days).strftime("%Y-%m-%d")
    @exams = Exam.order(:date_exam, :number).finder_exam(params[:q], params[:category], "#{date_exam_min}", Esodes::SESJA)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    render status: :ok,
           json: @exams_on_page, meta: {total_count: @exams.count}
  end

  def show
    exam = Exam.find_by(id: params[:id])
    if exam.present?
      render status: :ok, json: exam, root: false
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla Exam.where(id: #{params[:id]})" }
    end
  end

end
