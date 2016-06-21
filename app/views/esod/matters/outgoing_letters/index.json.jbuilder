json.array!(@esod_outgoing_letters) do |esod_outgoing_letter|
  json.extract! esod_outgoing_letter, :id, :nrid, :numer_ewidencyjny, :tytul, :identyfikator_rodzaju_dokumentu_wychodzacego, :data_pisma, :numer_wersji, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user
  json.url esod_outgoing_letter_url(esod_outgoing_letter, format: :json)
end
