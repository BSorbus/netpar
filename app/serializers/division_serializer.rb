class DivisionSerializer < ActiveModel::Serializer
  # attributes :id, :name, :english_name, :short_name, :number_prefix
  attributes :id, :name, :english_name, :short_name, :number_prefix, 
    :min_years_old, :face_image_required, :for_new_certificate, :proposal_via_internet, :category, :category_fullname, :id_with_name_with_short

end