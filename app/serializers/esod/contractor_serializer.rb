class Esod::ContractorSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :imie, :nazwisko, :nazwa, :drugie_imie, :tytul, :nip, :pesel, :rodzaj, :initialized_from_esod, :netpar_user

end
