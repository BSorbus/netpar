class Api::V1::GradeSerializer < ActiveModel::Serializer

  attributes :id, :examination_id, :subject_id, :grade_result, :testportal_access_code_id, :testportal_url


  def testportal_url
    "https://do testportalu"
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
