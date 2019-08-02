FactoryBot.define do
  factory :esod_contractor, class: 'Esod::Contractor' do
    nrid 1
    imie "MyString"
    nazwisko "MyString"
    nazwa "MyString"
    drugie_imie "MyString"
    tytul "MyString"
    nip "MyString"
    pesel "MyString"
    rodzaj ""
    initialized_from_esod false
    netpar_user ""
  end
end
