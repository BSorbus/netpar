class Api::V1::TestportalResultsController < Api::V1::BaseApiController

  skip_before_action :authenticate_system_from_token #, raise: false, only: [:custom_action_method]

  # wrap_parameters :testportal_results
  respond_to :json


  def create
    # params[:proposal] = JSON.parse params[:proposal].gsub('=>', ':')
    # puts '-----------------------------------------'
    # puts params
    # # puts params[:testportal_results]
    # # puts params[:testportal_results]
    # # puts params[:testportal_results]
    # puts params[:testResult]
    # puts params[:testResult][:accessCode]
    # puts '.........................................'
    # puts testportal_params
    # puts '-----------------------------------------'

    unless params[:testResult][:formattedPercents].present?
      render json: { errors: "'formattedPercents' parameter is missing" }, status: :not_acceptable
    else
      grade = Grade.find_by(testportal_access_code_id: params[:testResult][:accessCode])
      if grade.present?
        # if grade.update(testportal_params)

     puts '-----------------------------------------'
     puts   default = (params[:testResult][:percents] >= 60) ? { grade_result: "T" } : { grade_result: "N" }  
     puts '-----------------------------------------'
        puts default
        if grade.update(testportal_params)
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
      defaults = (params[:testResult][:percents] >= 60) ? { grade_result: "T" } : { grade_result: "N" }  
      params.require(:testResult).permit().reverse_merge(defaults)
    end


end
