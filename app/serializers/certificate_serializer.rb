class CertificateSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_of_issue, :valid_thru, :certificate_status, :note, :category

  #belongs_to :customer
  has_one :division
  has_one :customer


end
