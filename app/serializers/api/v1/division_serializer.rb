class Api::V1::DivisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :english_name, :short_name, :number_prefix, :category, :min_years_old, :face_image_required, :fullname

  def fullname
    "#{name}, [#{short_name}][ukończone #{min_years_old} lat]"
  end

end
