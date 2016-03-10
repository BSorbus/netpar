class PnaCodeSerializer < ActiveModel::Serializer
  attributes :id, :pna, :miejscowosc, :ulica, :numery, :wojewodztwo, :powiat, :gmina, :fullname

  def fullname
    "#{object.pna} - #{object.miejscowosc}, #{object.ulica} #{object.numery} [#{object.wojewodztwo}, #{object.powiat}, #{object.gmina}]"
  end

end
