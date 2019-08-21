class Api::V1::DivisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :english_name, :short_name, :number_prefix, :category, :min_years_old, :fullname

  def fullname
    "#{name}, [#{short_name}][ukończone #{min_years_old} lat]"
  end

end
