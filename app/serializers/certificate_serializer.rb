class CertificateSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_of_issue, :valid_thru, :note, :category, :fullname

  #belongs_to :customer
  has_one :division
  has_one :customer

  def fullname
    "#{number}, z dn. #{date_of_issue}, #{object.customer.fullname}, #{object.customer.pesel}"
  end

end

