require 'esodes'

class Api::V1::ExamsController < Api::V1::BaseApiController
  before_action :authenticate_with_token!#, only: [:update, :destroy]

  respond_to :json


  def show
    #authenticate_user!
    exam = Exam.find_by(id: params[:id])
    render status: :ok,
           json: exam, include: [:division] 
  end

  def lot
    authorize :exam, :index_l?

    if params[:date_exam_min].present?
      exams_all = Exam.where("category = 'L' AND date_exam >= '#{params[:date_exam_min]}'").order(:date_exam)
    else
      exams_all = Exam.where(category: "L").order(:date_exam)
    end

    exams = exams_all.order(:date_exam).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams_all.size } }
  end

  def mor
    authorize :exam, :index_m?

    if params[:date_exam_min].present?
      exams_all = Exam.where("category = 'M' AND date_exam >= '#{params[:date_exam_min]}'").order(:date_exam)
    else
      exams_all = Exam.where(category: "M").order(:date_exam)
    end

    exams = exams_all.order(:date_exam).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams_all.size } }
  end

  def ra
    authorize :exam, :index_r?

    if params[:date_exam_min].present?
      exams_all = Exam.where("category = 'R' AND date_exam >= '#{params[:date_exam_min]}'").order(:date_exam)
    else
      exams_all = Exam.where(category: "R").order(:date_exam)
    end

    exams = exams_all.order(:date_exam).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams_all.size } }
  end



  def mor_next_and_free
    params[:q] = params[:q]
    date_exam_min = (Time.zone.today + 14.days).strftime("%Y-%m-%d")
    @exams = Exam.order(:number).finder_exam(params[:q], "M", "#{date_exam_min}", Esodes::SESJA)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    # render status: :ok,
    #        json: @exams_on_page, each_serializer: ExamSerializer, meta: {total_count: @exams.count}

    render status: :ok,
           json: @exams_on_page, meta: {total_count: @exams.count}

  end


  def ra_next_and_free
    #params[:q] ||= ""
    params[:q] = params[:q]
    date_exam_min = (Time.zone.today + 14.days).strftime("%Y-%m-%d")
    @exams = Exam.order(:number).finder_exam(params[:q], "R", "#{date_exam_min}", Esodes::SESJA)
    @exams_on_page = @exams.page(params[:page]).per(params[:page_limit])

    # render status: :ok,
    #        json: @exams_on_page, each_serializer: ExamSerializer, meta: {total_count: @exams.count}

    render status: :ok,
           json: @exams_on_page, meta: {total_count: @exams.count}

  end








  def lot_search_by_number
    authorize :exam, :index_l?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      exams = Exam.where(category: "L", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if exams.present?
        render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'L', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def mor_search_by_number
    authorize :exam, :index_m?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      exams = Exam.where(category: "M", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if exams.present?
        render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'M', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def ra_search_by_number
    authorize :exam, :index_r?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      exams = Exam.where(category: "R", number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if exams.present?
        render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'R', number: '#{params[:number].upcase}')" }

      end
    end
  end

  def all_search_by_number
    authorize :exam, :index?

    if params[:number].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:number]" }
    else
      exams = Exam.where(number: params[:number].upcase).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
      if exams.present?
        render status: :ok,
           json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(number: '#{params[:number].upcase}')" }

      end
    end
  end

  def lot_search_by_customer_pesel
    authorize :exam, :index_l?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      exams = Exam.joins(examinations: [:customer]).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "L", customers: {pesel: params[:pesel]})
      if exams.present?
        render status: :ok,
               json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'L') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def mor_search_by_customer_pesel
    authorize :exam, :index_m?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      exams = Exam.joins(examinations: [:customer]).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "M", customers: {pesel: params[:pesel]})
      if exams.present?
        render status: :ok,
               json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'M') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def ra_search_by_customer_pesel
    authorize :exam, :index_r?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      exams = Exam.joins(examinations: [:customer]).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(category: "R", customers: {pesel: params[:pesel]})
      if exams.present?
        render status: :ok,
               json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Exam.where(category: 'R') AND Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end

  def all_search_by_customer_pesel
    authorize :exam, :index?

    if params[:pesel].blank?
      render status: :not_acceptable,
             json: { error: "Brak parametru [:pesel]" }
    else
      exams = Exam.joins(examinations: [:customer]).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).where(customers: {pesel: params[:pesel]})
      if exams.present?
        render status: :ok,
               json: exams, meta: { collection:
                               { offset: params[:offset] ||= 0,
                                 limit: params[:limit] ||= 10,
                                 objects: exams.size } }
      else
        render status: :not_found,
               json: { error: "Brak rekordów dla Customer.where(pesel: '#{params[:pesel]}')" }

      end
    end
  end


end
