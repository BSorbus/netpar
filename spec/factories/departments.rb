FactoryBot.define do
  factory :department do
    sequence(:short) { |n| "D#{n}" }
    sequence(:name) { |n| "Name #{n}" }
    #short "DEP"
    #name "Test Department"
    address_city "Address City"
    address_street "Address Street"
    address_house "1"
    address_number "1"
    address_postal_code "00-000"
    phone "phone"
    fax "fax"
    email "t.d@uke.gov.pl"
    director "Director"
  end

end
