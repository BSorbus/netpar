class CreateEsodIncomingLetters < ActiveRecord::Migration
  def change
    create_table :esod_incoming_letters do |t|
      t.integer :nrid, limit: 8
      t.string :numer_ewidencyjny
      t.string :tytul, index: true
      t.date :data_pisma
      t.date :data_nadania
      t.date :data_wplyniecia
      t.string :znak_pisma_wplywajacego
      t.integer :identyfikator_typu_dcmd
      t.integer :identyfikator_rodzaju_dokumentu
      t.integer :identyfikator_sposobu_przeslania
      t.integer :identyfikator_miejsca_przechowywania
      t.date :termin_na_odpowiedz
      t.boolean :pelna_wersja_cyfrowa
      t.boolean :naturalny_elektroniczny
      t.integer :liczba_zalacznikow
      t.string :uwagi
      t.integer :identyfikator_osoby, limit: 8
      t.integer :identyfikator_adresu, limit: 8
      t.references :esod_contractor, index: true, foreign_key: true
      t.references :esod_address, index: true, foreign_key: true

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
