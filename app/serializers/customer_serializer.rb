class CustomerSerializer < ActiveModel::Serializer
  #attributes *Customer.column_names
  attributes :id, :human, :name, :given_names,
    :address_city, :address_street, :address_house, :address_number, :address_postal_code, :address_post_office, :address_pobox, 
    :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code, :c_address_post_office, :c_address_pobox,
    :nip, :regon, :pesel, :birth_date, :birth_place, :fathers_name, :mothers_name, :family_name, 
    :phone, :fax, :email, :note, :user_id, :created_at, :updated_at, :fullname_and_address_and_pesel_nip_and_birth_date  


  has_one :citizenship
  has_one :address_teryt_pna_code
  has_one :c_address_teryt_pna_code


end
