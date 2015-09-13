json.array!(@exams) do |exam|
  json.extract! exam, :id, :number, :date_exam, :place_exam, :chairman, :secretary, :category, :note, :user_id
  json.url exam_url(exam, format: :json)
end
