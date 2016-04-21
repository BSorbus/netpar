class Teryt::PnaCodeSerializer < ActiveModel::Serializer
  attributes :id, :pna, :woj_nazwa, :pow_nazwa, :gmi_nazwa, :rodz_gmi_nazwa, :rm_nazwa, :sym_nazwa, :sympod_nazwa, :mie_nazwa, :uli_nazwa, :cecha, :numery, :fullname, :numery_info, :woj_pow_gmi_mie_info, :teryt, :pna_teryt

  def fullname
    "#{object.mie_nazwa}, #{object.uli_nazwa}, #{object.pna} [#{object.woj_nazwa}, #{object.pow_nazwa}, #{object.gmi_nazwa}]"
  end

  def numery_info
    object.numery.present? ? "[numery: #{object.numery}]" : ""
  end

  def woj_pow_gmi_mie_info
    "#{object.rm_nazwa} [#{object.woj_nazwa}, #{object.pow_nazwa}, #{object.gmi_nazwa}]"
  end

end
