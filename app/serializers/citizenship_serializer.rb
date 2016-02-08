class CitizenshipSerializer < ActiveModel::Serializer
  attributes :id, :name, :short

  #has_many :customers
  #has_many :exams
end
