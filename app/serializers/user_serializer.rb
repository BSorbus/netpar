class UserSerializer < ActiveModel::Serializer
  attributes :name, :email, :authentication_token

  #has_many :customers
  #has_many :exams
end
