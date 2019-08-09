require 'esodes'

class Api::V1::ExamsController < Api::V1::BaseApiController

  respond_to :json


  def show
    exam = Exam.find_by(id: params[:id])
    if exam.present?
      render status: :ok, json: exam, root: false
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla Exam.where(id: #{params[:id]})" }
    end
  end


  def mor_next_and_free
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    date_exam_min = (Time.zone.today + 14.days).strftime("%Y-%m-%d")
    @exams = Exam.order(:date_exam).finder_exam(params[:q], "M", "#{date_exam_min}", Esodes::SESJA)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    # render status: :ok,
    #        json: @exams_on_page, each_serializer: ExamSerializer, meta: {total_count: @exams.count}

    render status: :ok,
           json: @exams_on_page, meta: {total_count: @exams.count}

  end


  def ra_next_and_free
    params[:q] = params[:q]
    params[:page] = params[:page]
    params[:page_limit] = params[:page_limit]
    date_exam_min = (Time.zone.today + 14.days).strftime("%Y-%m-%d")
    @exams = Exam.order(:date_exam).finder_exam(params[:q], "R", "#{date_exam_min}", Esodes::SESJA)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    # render status: :ok,
    #        json: @exams_on_page, each_serializer: ExamSerializer, meta: {total_count: @exams.count}

    render status: :ok,
           json: @exams_on_page, meta: {total_count: @exams.count}

  end

end
