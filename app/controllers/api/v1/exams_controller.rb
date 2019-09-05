require 'esodes'

class Api::V1::ExamsController < Api::V1::BaseApiController

  respond_to :json


  def index
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    params[:division_id] = params[:division_id]

    date_exam_min = (Time.zone.today + 7.days).strftime("%Y-%m-%d")
    # Pokaż tylko sesje typu EGZAMIN, które będą nie wcześniej niż za 14 dni oraz dla których są wolne miejsca
    extend_condition = "(exams.esod_category = #{Esodes::SESJA}) AND (exams.date_exam >= '#{date_exam_min}') AND (examinations_count + proposals_important_count < max_examinations)" 

    @exams = Exam.joins(:divisions).where(divisions: {id: params[:division_id]}).where("#{extend_condition}").order(:date_exam, :number).finder_exam(params[:q], params[:category])
    #@exams = Exam.where("#{extend_condition}").order(:date_exam, :number).finder_exam(params[:q], params[:category])
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
