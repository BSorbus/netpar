json.array!(@esod_internal_letters) do |esod_internal_letter|
  json.extract! esod_internal_letter, :id, :nrid, :numer_ewidencyjny, :tytul, :uwagi, :identyfikator_rodzaju_dokumentu_wewnetrznego, :identyfikator_typu_dcmd, :identyfikator_dostepnosci_dokumentu, :pelna_wersja_cyfrowa, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user
  json.url esod_internal_letter_url(esod_internal_letter, format: :json)
end
