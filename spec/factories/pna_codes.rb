FactoryGirl.define do
  factory :pna_code do
    sequence(:pna) { |n| "00-00#{n}" }
    miejscowosc "MyString"
    ulica "MyString"
    numery "MyString"
    wojewodztwo "MyString"
    powiat "MyString"
    gmina "MyString"
  end

end
