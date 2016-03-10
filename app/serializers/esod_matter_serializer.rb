class EsodMatterSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :znak, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :adnotacja, :identyfikator_stanowiska_referenta, :czy_otwarta, :esod_created_at, :esod_updated_et
end
