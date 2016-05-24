class CreateEsodOutgoingLetters < ActiveRecord::Migration
  def change
    create_table :esod_outgoing_letters do |t|
      t.integer :nrid, limit: 8
      t.string :numer_ewidencyjny
      t.string :tytul, index: true
      t.integer :wysylka
      t.integer :identyfikator_adresu, limit: 8
      t.integer :identyfikator_sposobu_wysylki
      t.integer :identyfikator_rodzaju_dokumentu_wychodzacego
      t.date :data_pisma
      t.integer :numer_wersji
      t.string :uwagi
      t.boolean :zakoncz_sprawe, default: true
      t.boolean :zaakceptuj_dokument, default: true

      t.date :data_utworzenia
      t.integer :identyfikator_osoby_tworzacej
      t.date :data_modyfikacji
      t.integer :identyfikator_osoby_modyfikujacej

      t.boolean :initialized_from_esod, default: false
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
