class Api::V1::DivisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :english_name, :short_name, :number_prefix, :category, :min_years_old, :face_image_required,
    :for_new_certificate, :proposal_via_internet, :enabled_in_confirmation, :confirmation_issued_from, :fullname

  def fullname
    if "#{object.category}" == 'R' 
      "#{name}, [#{short_name}]"
    else
      "#{name}, [#{short_name}][ukończone #{min_years_old} lat]"
    end
  end

end
