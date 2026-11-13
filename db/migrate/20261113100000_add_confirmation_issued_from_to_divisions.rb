# Weryfikacja w Confirmation tylko świadectw wydanych od podanego dnia (włącznie) – osobno dla każdego rodzaju;
# domyślnie 2000-01-01 (także dla istniejących rodzajów – PostgreSQL wpisuje wartość domyślną w istniejących rekordach);
# puste (ustawione w panelu) – bez ograniczenia. Wcześniejsze: API odpowiada 403 (reason: issued_before_limit) zamiast
# „brak danych”, żeby prawdziwe stare świadectwo nie wyglądało na nieistniejące.
class AddConfirmationIssuedFromToDivisions < ActiveRecord::Migration
  def change
    add_column :divisions, :confirmation_issued_from, :date, default: '2000-01-01'
  end
end
