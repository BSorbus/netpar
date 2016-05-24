class Esod::MatterSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod, :fullname, :iks_name, :flat_all_matter_notes, :exam_number, :exam_place


end
