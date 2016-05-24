class Esod::IncomingLetterSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :numer_ewidencyjny, :tytul, :data_pisma, :data_nadania, :data_wplyniecia, :znak_pisma_wplywajacego, :identyfikator_typu_dcmd, :identyfikator_rodzaju_dokumentu, :identyfikator_sposobu_przeslania, :identyfikator_miejsca_przechowywania, :termin_na_odpowiedz, :pelna_wersja_cyfrowa, :naturalny_elektroniczny, :uwagi, :identyfikator_osoby, :identyfikator_adresu, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user
  has_one :esod_contractor
  has_one :esod_address
end
