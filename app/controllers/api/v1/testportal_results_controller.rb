class Api::V1::TestportalResultsController < Api::V1::BaseApiController

  skip_before_action :authenticate_system_from_token #, raise: false, only: [:custom_action_method]

  # wrap_parameters :testportal_results
  respond_to :json


  def create
    unless params[:testResult][:percents].present?
      render json: { errors: "'percents' parameter is missing" }, status: :not_acceptable
    else
      grade = Grade.find_by(testportal_access_code_id: params[:testResult][:accessCode])
      if grade.present?
        # if grade.update(testportal_params)
        grade.grade_result = (params[:testResult][:percents] >= 60) ? "P" : "N"
        if grade.save
            render json: { message: "Result saved" }, status: :ok
        else
          render json: { errors: grade.errors }, status: :unprocessable_entity
        end
      else
        render json: { error: "Not found accessCode: #{params[:testResult][:accessCode]}" }, status: :not_found
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def testportal_params
      defaults = (params[:testResult][:percents] >= 60) ? { grade_result: "P" } : { grade_result: "N" }  
      params.require(:testResult).permit(:grade_result).reverse_merge(defaults)
    end


end
