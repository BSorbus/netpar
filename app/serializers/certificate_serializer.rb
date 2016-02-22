class CertificateSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_of_issue, :valid_thru, :certificate_status, :note, :category, :url, :image_url

  #belongs_to :customer
  has_one :division
  has_one :customer

  def url
    { self: api_v1_certificate_path(object) }
  end

  def image_url
    attach = object.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last
    #{ self: refile_app_path(attach, attach.filename) }
    if attach.present?
      { id: attach.id, fileattach_filename: attach.fileattach_filename, fileattach_size: attach.fileattach_size,
        attachment_url: "..."  }
    else  
      {}
    end
  end


end
