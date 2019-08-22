class ProposalSerializer < ActiveModel::Serializer
  attributes :id, :name, :given_names, :pesel, :birth_date, :address_city, :category, :fullname

  #belongs_to :customer

  def fullname
    "#{name} #{given_names}"
  end

end

