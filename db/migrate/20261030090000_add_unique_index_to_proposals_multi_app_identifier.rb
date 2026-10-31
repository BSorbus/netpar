# Jedno zgłoszenie na multi_app_identifier – bez duplikatów z podwójnego kliknięcia albo ponowionego wysłania
# (Api::V1::ProposalsController#create zwraca wtedy istniejące zgłoszenie).
#
# Indeks częściowy: obejmuje zgłoszenia utworzone od uruchomienia tej migracji. Starsze duplikaty (m.in. anulowane,
# o których poinformowano wnioskodawców) zostają bez zmian, więc indeks pełny nie jest możliwy.
class AddUniqueIndexToProposalsMultiAppIdentifier < ActiveRecord::Migration
  INDEX = "index_proposals_on_multi_app_identifier_unique_new"

  def up
    cutoff = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    execute "CREATE UNIQUE INDEX #{INDEX} ON proposals (multi_app_identifier) WHERE created_at >= '#{cutoff}'"
  end

  def down
    execute "DROP INDEX IF EXISTS #{INDEX}"
  end
end
