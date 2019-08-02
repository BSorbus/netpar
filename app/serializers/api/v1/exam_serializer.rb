class Api::V1::ExamSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_exam, :place_exam, :province_id, :examinations_count, :max_examinations, :category, :fullname

  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
  end

end
