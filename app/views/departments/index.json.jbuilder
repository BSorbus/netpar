json.array!(@departments) do |department|
  json.extract! department, :id, :short, :name, :address_city, :address_street, :adress_house, :address_number, :phone, :email, :director
  json.url department_url(department, format: :json)
end
