json.array!(@individuals) do |individual|
  json.extract! individual, :id, :number, :date_of_issue, :valid_thru, :license_status, :application_date, :call_sign, :category, :transmitter_power, :certificate_number, :certificate_date_of_issue, :certificate_id, :payment_code, :payment_date, :station_city, :station_street, :station_house, :station_number, :customer_id, :note, :user_id
  json.url individual_url(individual, format: :json)
end
