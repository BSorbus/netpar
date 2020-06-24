class ExamSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_exam, :place_exam, :info, :chairman, :secretary, :category, :note, :user_id, :created_at, :updated_at, :fullname

  #has_one :user

end
