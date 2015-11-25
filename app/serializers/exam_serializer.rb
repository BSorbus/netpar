class ExamSerializer < ActiveModel::Serializer
  attributes :id, :number, :date_exam, :place_exam, :chairman, :secretary, :category, :note, :user_id, :created_at, :updated_at, :fullname, :test

  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
  end

  def test
    "--TEST--"
  end

end
