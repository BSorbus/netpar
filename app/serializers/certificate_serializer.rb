class CertificateSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_of_issue, :valid_thru, :certificate_status, :note, :category, :url

  #belongs_to :customer
  has_one :division
  has_one :customer

  def url
    { self: api_v1_certificate_path(object) }
  end

end
