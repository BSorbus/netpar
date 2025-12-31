class Api::V1::ExamFeesController < Api::V1::BaseApiController


  respond_to :json

  def show
    exam_fee = ExamFee.find_by(id: params[:id])
    if exam_fee.present?
      render status: :ok, json: exam_fee, root: false
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla ExamFee.where(id: #{params[:id]})" }
    end
  end

  def find
    checked_date = params[:for_date] || Time.zone.today
    exam_fee = ExamFee.for_date(checked_date).find_by(division_id: params[:division_id], esod_category: params[:esod_category])
    if exam_fee.present?
      render status: :ok, json: exam_fee, root: false
    else
      render status: :not_found,
             json: { error: "Brak rekordu dla ExamFee.where(division_id: #{params[:division_id]}, esod_category: #{params[:esod_category]})" }
    end
  end

end
