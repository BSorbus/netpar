class Api::V1::GradeSerializer < ActiveModel::Serializer

  attributes :id, :examination_id, :subject_id, :grade_result, :testportal_access_code_id, :subject_name, :testportal_test_info

  def testportal_test_info
    # data = {}
    # id_test = ExamsDivisionsSubject.joins(:exams_division, exams_division: [:exam]).where(subject: object.subject, exams_divisions: {division_id: object.examination.division_id} ).first.testportal_test_id
    # api_call_correct, test_hash = ApiTestportalTest::test_info_in_testportal_where_test_id("#{id_test}")
    # if api_call_correct
    #   data = test_hash unless test_hash.blank?
    # end 
    data = {}
    id_test = ExamsDivisionsSubject.joins(:exams_division, exams_division: [:exam]).where(subject_id: object.subject_id, exams_divisions: {division_id: object.examination.division_id} ).uniq.first.testportal_test_id
    api_call_correct, test_hash = ApiTestportalTest::test_info_in_testportal_where_test_id("#{id_test}")
    if api_call_correct
      data = test_hash unless test_hash.blank?
    end 
  end

  def subject_name
    "#{object.subject.name}"    
  end

  # attributes :id, :number, :date_of_issue, :valid_thru, :note, :category, :url, :document_image

  # #belongs_to :customer
  # has_one :division
  # has_one :customer

  # def url
  #   { self: api_v1_certificate_path(object) }
  # end

  # def document_image
  #   attach = object.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last
  #   if attach.present?
  #     { id: attach.id, 
  #       filename: attach.fileattach_filename,
  #       content_type: attach.fileattach_content_type, 
  #       size: attach.fileattach_size,
  #       url: Refile.attachment_url(attach, :fileattach, prefix: api_v1_refile_app_path)
  #     }
  #   else  
  #     {}
  #   end
  # end


end

