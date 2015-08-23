json.array!(@certificates) do |certificate|
  json.extract! certificate, :id, :number, :date_of_issue, :valid_thru, :exam_id, :category, :note, :user_id
  json.url certificate_url(certificate, format: :json)
end
