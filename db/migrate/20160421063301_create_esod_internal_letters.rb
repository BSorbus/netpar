class CreateEsodInternalLetters < ActiveRecord::Migration
  def change
    create_table :esod_internal_letters do |t|
      t.integer :nrid
      t.string :numer_ewidencyjny
      t.string :tytul
      t.string :uwagi
      t.integer :identyfikator_rodzaju_dokumentu_wewnetrznego
      t.integer :identyfikator_typu_dcmd
      t.integer :identyfikator_dostepnosci_dokumentu
      t.boolean :pelna_wersja_cyfrowa
      t.integer :id_zalozyl
      t.integer :id_aktualizowal
      t.date :data_zalozenia
      t.date :data_aktualizacji
      t.boolean :initialized_from_esod
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
