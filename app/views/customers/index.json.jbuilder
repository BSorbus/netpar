json.array!(@customers) do |customer|
  json.extract! customer, :id, :human, :name, :given_names, :address_city, :address_street, :address_house, :address_number, :address_postal_code, :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code, :nip, :regon, :pesel, :birth_date, :birth_place, :fathers_name, :mothers_name, :family_name, :citizenship_id, :phone, :fax, :email, :note, :user_id
  json.url customer_url(customer, format: :json)
end
