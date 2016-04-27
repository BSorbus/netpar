json.array!(@esod_incoming_letters) do |esod_incoming_letter|
  json.extract! esod_incoming_letter, :id, :nrid, :numer_ewidencyjny, :tytul, :data_pisma, :data_nadania, :data_wplyniecia, :znak_pisma_wplywajacego, :identyfikator_typu_dcmd, :identyfikator_rodzaju_dokumentu, :identyfikator_sposobu_przeslania, :identyfikator_miejsca_przechowywania, :termin_na_odpowiedz, :pelna_wersja_cyfrowa, :naturalny_elektroniczny, :uwagi, :id_osoba, :id_adres, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :esod_contractor_id, :esod_address_id, :initialized_from_esod, :netpar_user
  json.url esod_incoming_letter_url(esod_incoming_letter, format: :json)
end
