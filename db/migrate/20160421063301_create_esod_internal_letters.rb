class CreateEsodInternalLetters < ActiveRecord::Migration
  def change
    create_table :esod_internal_letters do |t|
      t.integer :nrid, limit: 8
      t.string :numer_ewidencyjny
      t.string :tytul, index: true
      t.string :uwagi
      t.integer :identyfikator_rodzaju_dokumentu_wewnetrznego
      t.integer :identyfikator_typu_dcmd
      t.integer :identyfikator_dostepnosci_dokumentu
      t.boolean :pelna_wersja_cyfrowa

      t.datetime :data_utworzenia
      t.integer :identyfikator_osoby_tworzacej
      t.datetime :data_modyfikacji
      t.integer :identyfikator_osoby_modyfikujacej
      t.boolean :initialized_from_esod, default: false
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
