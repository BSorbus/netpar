FactoryGirl.define do
  factory :esod_internal_letter, class: 'Esod::InternalLetter' do
    nrid 1
    numer_ewidencyjny "MyString"
    tytul "MyString"
    uwagi "MyString"
    identyfikator_rodzaju_dokumentu_wewnetrznego 1
    identyfikator_typu_dcmd 1
    identyfikator_dostepnosci_dokumentu 1
    pelna_wersja_cyfrowa false
    id_zalozyl 1
    id_aktualizowal 1
    data_zalozenia "2016-04-21"
    data_aktualizacji "2016-04-21"
    initialized_from_esod false
    netpar_user 1
  end
end
