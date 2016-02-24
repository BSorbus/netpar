#require 'refile'
class CertificateSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_of_issue, :valid_thru, :certificate_status, :note, :category, :url, :document_image

  #belongs_to :customer
  has_one :division
  has_one :customer

  def url
    { self: api_v1_certificate_path(object) }
  end

  def document_image
    attach = object.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last
    #{ self: refile_app_path(attach, attach.filename) }
    if attach.present?
      { id: attach.id, 
        filename: attach.fileattach_filename,
        content_type: attach.fileattach_content_type, 
        size: attach.fileattach_size,
        url: Refile.attachment_url(attach, :fileattach)
      }
    else  
      {}
    end
  end


end

