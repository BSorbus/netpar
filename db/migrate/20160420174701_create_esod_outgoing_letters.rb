class CreateEsodOutgoingLetters < ActiveRecord::Migration
  def change
    create_table :esod_outgoing_letters do |t|
      t.integer :nrid
      t.string :numer_ewidencyjny
      t.string :tytul
      t.integer :wysylka
      t.integer :identyfikator_rodzaju_dokumentu_wychodzacego
      t.date :data_pisma
      t.integer :numer_wersji
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
