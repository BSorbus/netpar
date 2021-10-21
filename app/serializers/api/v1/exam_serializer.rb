class Api::V1::ExamSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_exam, :place_exam, :info, :province_id, :province_name, :examinations_count, :max_examinations, :category, :online, :fullname

  def fullname
    "#{number}, #{date_exam}, #{place_exam}" + "#{province_name_with_quote}" + "#{info}"
  end

  def province_name_with_quote
  	online ? " [online], " : " [#{province_name}], "
  end

end
