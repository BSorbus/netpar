json.array!(@exams) do |exam|
  json.extract! exam, :id, :number, :date_exam, :place_exam, :chairman, :secretary, :committee_member1, :committee_member2, :committee_member3, :category, :note, :user_id
  json.url exam_url(exam, format: :json)
end
