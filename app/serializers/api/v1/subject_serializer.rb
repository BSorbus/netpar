# Przedmiot egzaminu dla rodzaju świadectwa (ekran rodzaju w NETPAR: „Egzamin obejmuje przedmioty”).
#   esod_categories – rodzaje zgłoszeń, w których przedmiot obowiązuje (Esodes: 41 egzamin, 42 egzamin poprawkowy, …)
#   test_template   – identyfikator wzorca testu w TestPortal (pusty – brak wzorca)
class Api::V1::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :item, :name, :esod_categories, :test_template

  def esod_categories
    object.esod_categories.map(&:to_i)
  end
end
