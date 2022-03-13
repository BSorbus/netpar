class Api::V1::GradeWithResultSerializer < ActiveModel::Serializer

  attributes :id, :examination_id, :subject_id, :subject_name, :grade_result

  def subject_name
    "#{object.subject.name}"    
  end

end

