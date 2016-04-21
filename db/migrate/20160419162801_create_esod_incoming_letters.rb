class CreateEsodIncomingLetters < ActiveRecord::Migration
  def change
    create_table :esod_incoming_letters do |t|
      t.integer :nrid, index: true
      t.string :numer_ewidencyjny
      t.string :tytul
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
      t.string :uwagi
      t.integer :id_osoba
      t.integer :id_adres
      t.integer :id_zalozyl
      t.string :id_aktualizowal
      t.date :data_zalozenia
      t.date :data_aktualizacji
      t.references :esod_contractor, index: true, foreign_key: true
      t.references :esod_address, index: true, foreign_key: true
      t.boolean :initialized_from_esod
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
