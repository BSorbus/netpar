FactoryGirl.define do
  factory :esod_address, class: 'Esod::Address' do
    nrid 1
    miasto "MyString"
    kod_pocztowy "MyString"
    ulica "MyString"
    numer_lokalu "MyString"
    numer_budynku "MyString"
    skrytka_epuap "MyString"
    panstwo "MyString"
    email "MyString"
    typ "MyString"
    initialized_from_esod false
    netpar_user 1
  end
end
