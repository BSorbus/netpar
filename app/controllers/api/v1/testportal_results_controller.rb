class Api::V1::TestportalResultsController < Api::V1::BaseApiController

  skip_before_action :authenticate_system_from_token #, raise: false, only: [:custom_action_method]

  # wrap_parameters :testportal_results
  respond_to :json


  def create
    # params[:proposal] = JSON.parse params[:proposal].gsub('=>', ':')

    puts '-----------------------------------------'
    puts params
    # puts params[:testportal_results]
    # puts params[:testportal_results]
    # puts params[:testportal_results]
    puts params[:testResult]
    puts params[:testResult][:accessCode]
    puts '.........................................'
    puts testportal_params

    puts '-----------------------------------------'

# {
#   "notificationType": "TEST_RESULT",
#   "testResult": {
#     "attemptEndTimeInMs": 1465383974131,
#     "attemptEndTimeString": "2016-06-08 13:06",
#     "attemptNumber": 1,
#     "attemptStartTimeInMs": 1465383877872,
#     "attemptStartTimeString": "2016-06-08 13:04",
#     "attemptVersion": 14,
#     "attemptsCount": 1,
#     "certificateStatus": "NOT_SENT",
#     "descriptiveGrade": null,
#     "email": "a.nowak@gmail.com",
#     "firstName": "Adam",
#     "formattedPercents": 75,
#     "hasUnmakredAnswer": null,
#     "honestRespondentBlockade": null,
#     "id": "IMPNti5Ku_HDKc3COFfPR6rT8Ih9U1MV-uaWniTXT8G78apizgLc1Th85Op3t76LhA",
#     "idAttempt": "II8nyhBBB1iD9fhyU1N2EwSzG2q0jfqKELFOYBKDhEe3Y9cJ-dZGhmHeLyjMTsjPFw",
#     "idGradingRange": "IFxNL4tQZzc7qMxiZEM4redZfcs3ujIxqgeTIZoHFw29il3hGwYcYmifxo2j2-D1sQ",
#     "idParentUser": null,
#     "idRespondent": "ID9jLFDtU_mR5a3NKO5wSH88wCWldJNp3DvcYp0GN5_gknGaEd5Pd6K8YQcT97iHRw",
#     "idTerm": "IEbgZ0U2dl5JeC4q1QMjOtPYFHVd5fOG8Z64ivv6_TBroswIzO_9sBhqrbt8TpuSYg",
#     "idTest": "IOU3hf4dkxeg43S1ZG_JPaiQ9_IcxtSADmz41RxykzKhUzn8RXj3MjAFNZz57T97rA",
#     "idUser": 2,
#     "idVariant": null,
#     "instuctionStartTime": "2016-06-08T13:03:39",
#     "lastName": "Nowak",
#     "mark": "Średniozaawansowany – B2",
#     "maxScore": 8,
#     "notified": "NOT_SENT",
#     "notifyOnActivation": false,
#     "accessCode": null,
#     "passed": null,
#     "percents": 75,
#     "personUID": 1234,
#     "questionsCount": 8,
#     "remainingTimeInMs": 1715382,
#     "respondentDisplayName": "Nowak Adam (a.nowak@gmail.com)",
#     "respondentIdVariant": null,
#     "respondentPersonalDescription": "Nowak Adam (a.nowak@gmail.com)",
#     "resultMailSent": false,
#     "score": 6,
#     "sumOfWindowBlurs": 0,
#     "termNumber": 3,
#     "testCategoryName": "Testy z angielskiego",
#     "testCreationTimeInMs": 1423432873415,
#     "testCreationTimeString": "2015-02-08 23:01",
#     "testDescription": "",
#     "testStatus": "Aktywny",
#     "testname": "Test poziomujący z j. angielskiego",
#     "totalTimeSpent": 84618,
#     "totalTimeSpentString": "01:25",
#     "userEmail": "tests@example.com",
#     "variantLetter": null
#   }



    # proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    # if proposal.present?
    #   if proposal.update(proposal_params)
    #     render json: proposal, status: :ok
    #   else
    #     render json: { errors: proposal.errors }, status: :unprocessable_entity
    #   end
    # else
    #   render json: { error: "Brak rekordu dla Proposal.where(multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    # end

    grade = Grade.find_by(testportal_access_code_id: params[:testResult][:accessCode])
    if grade.present?
      if grade.update(testportal_params)
          render json: { message: "Result saved" }, status: :ok
      else
        render json: { errors: grade.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "Not found accessCode: #{params[:testResult][:accessCode]}" }, status: :not_found
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def testportal_params
      defaults = (params[:testResult][:formattedPercents] >= 60) ? { grade_result: "T" } : { grade_result: "N" }  
      params.require(:testResult).permit().reverse_merge(defaults)
    end


end
