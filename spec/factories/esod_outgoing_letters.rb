FactoryGirl.define do
  factory :esod_outgoing_letter, class: 'Esod::OutgoingLetter' do
    nrid 1
    numer_ewidencyjny "MyString"
    tytul "MyString"
    wysylka 1
    identyfikator_rodzaju_dokumentu_wychodzacego 1
    data_pisma "2016-04-20"
    numer_wersji 1
    id_zalozyl 1
    id_aktualizowal 1
    data_zalozenia "2016-04-20"
    data_aktualizacji "2016-04-20"
    initialized_from_esod false
    netpar_user 1
  end
end
