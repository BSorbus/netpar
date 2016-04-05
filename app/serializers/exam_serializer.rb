class ExamSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_exam, :place_exam, :chairman, :secretary, :category, :note, :user_id, :created_at, :updated_at, :fullname, :test

  #has_one :user

  def fullname
    "#{object.number}, z dn. #{object.date_exam}, #{object.place_exam}"
  end

  def test
    "--TEST--"
  end

end
