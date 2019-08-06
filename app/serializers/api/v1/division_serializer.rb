class Api::V1::DivisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :english_name, :short_name, :number_prefix, :category, :fullname

  def fullname
    "#{name}, [#{short_name}]"
  end

end
