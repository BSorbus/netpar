FactoryGirl.define do
  factory :customer do
    human false
    sequence(:name) { |n| "Cust Name #{n}" }
    #name "Cust Test Name"
    given_names "Cust Given Names"
    address_city "Address City"
    address_street "Address Street"
    address_house "1"
    address_number "1"
    address_postal_code "00-000"
    c_address_city "C Address City"
    c_address_street "C Address Street"
    c_address_house "C 1"
    c_address_number "C 1"
    c_address_postal_code "00-001"
    nip "nip"
    regon "regon"
    pesel "69070610092"
    birth_date "1969-07-06"
    birth_place "Birth Place"
    fathers_name "Father"
    mothers_name "Mother"
    family_name "Famili"
    citizenship nil
    phone "phone"
    fax "fax"
    email "t.c@uke.gov.pl"
    note "MyText"
    user nil
    address_teryt_pna_code nil
    c_address_teryt_pna_code nil
    address_in_poland true
    c_address_in_poland true
  end

end
