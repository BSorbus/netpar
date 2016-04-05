FactoryGirl.define do
  factory :esod_matter, class: 'Esod::Matter' do
    sequence(:nrid) { |n| n }
    sequence(:znak) { |n| "znak#{n}" }
    znak_sprawy_grupujacej "MyString"
    symbol_jrwa "MyString"
    tytul "MyString"
    termin_realizacji "2016-03-30"
    identyfikator_kategorii_sprawy 1
    adnotacja "MyString"
    identyfikator_stanowiska_referenta 1
    czy_otwarta false
    data_utworzenia "2016-03-30 07:35:52"
    data_modyfikacji "2016-03-30 07:35:52"
    initialized_from_esod false
#    exam nil
#    examination nil
#    certificate nil
  end
end
