include  ActionView::Helpers::TextHelper

class Esod::MatterSerializer < ActiveModel::Serializer
  attributes :id, :nrid, :znak, :znak_sprawy_grupujacej, :symbol_jrwa, :tytul, :termin_realizacji, :identyfikator_kategorii_sprawy, :adnotacja, :identyfikator_stanowiska_referenta, :czy_otwarta, :data_utworzenia, :data_modyfikacji, :initialized_from_esod, :fullname, :iks_name, :exam_number, :exam_place

  def fullname
    "#{object.znak}, #{truncate(object.tytul, length: 85)}, #{object.termin_realizacji}, [#{iks_name}]"
  end

  def iks_name
    case object.identyfikator_kategorii_sprawy
    when 41
      'Wniosek o wydanie świadectwa'
    when 42
      'Wniosek o egzamin poprawkowy'
    when 43
      'Wniosek o odnowienie bez egzaminu'
    when 44
      'Wniosek o odnowienie z egzaminem'
    when 45
      'Wniosek o duplikat'
    when 46
      'Wniosek o wymianę świadectwa'
    when 47
      'Sesja egzaminacyjna'
    when 48
      'Protokół egzaminacyjny'
    else
      "Error identyfikator_kategorii_sprawy value (#{object.identyfikator_kategorii_sprawy})!"
    end
  end

  def exam_number
    "#{object.tytul}".split(%r{,\s*})[0]
  end

  def exam_place
    "#{object.tytul}".split(%r{,\s*})[1]
  end

end
