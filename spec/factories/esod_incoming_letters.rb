FactoryBot.define do
  factory :esod_incoming_letter, class: 'Esod::IncomingLetter' do
    nrid 1
    numer_ewidencyjny "MyString"
    tytul "MyString"
    data_pisma "2016-04-19"
    data_nadania "2016-04-19"
    data_wplyniecia "2016-04-19"
    znak_pisma_wplywajacego "MyString"
    identyfikator_typu_dcmd 1
    identyfikator_rodzaju_dokumentu 1
    identyfikator_sposobu_przeslania 1
    identyfikator_miejsca_przechowywania 1
    termin_na_odpowiedz "2016-04-19"
    pelna_wersja_cyfrowa false
    naturalny_elektroniczny false
    uwagi "MyString"
    identyfikator_osoby 1
    identyfikator_adresu 1
    id_zalozyl 1
    id_aktualizowal "MyString"
    data_zalozenia "2016-04-19"
    data_aktualizacji "2016-04-19"
    esod_contractor nil
    esod_address nil
    initialized_from_esod false
    netpar_user 1
  end
end
