class Esod::OutgoingLetterSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :numer_ewidencyjny, :tytul, :wysylka, :identyfikator_rodzaju_dokumentu_wychodzacego, :data_pisma, :numer_wersji, :id_zalozyl, :id_aktualizowal, :data_zalozenia, :data_aktualizacji, :initialized_from_esod, :netpar_user
end
