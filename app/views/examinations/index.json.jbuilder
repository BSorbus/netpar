json.array!(@examinations) do |examination|
  json.extract! examination, :id, :examination_category, :division_id, :examination_result, :exam_id, :customer_id, :certificate_id, :note, :category, :exam_id, :user_id
  json.url examination_url(examination, format: :json)
end
