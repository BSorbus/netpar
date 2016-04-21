class CreateEsodMatters < ActiveRecord::Migration
  def change
    create_table :esod_matters do |t|
      t.integer :nrid, index: true
      t.string :znak
      t.string :znak_sprawy_grupujacej
      t.string :symbol_jrwa
      t.string :tytul
      t.date :termin_realizacji
      t.integer :identyfikator_kategorii_sprawy
      t.string :adnotacja
      t.integer :identyfikator_stanowiska_referenta
      t.boolean :czy_otwarta
      t.datetime :data_utworzenia
      t.datetime :data_modyfikacji
      t.integer :id_zalozyl
      t.integer :id_aktualizowal
      t.boolean :initialized_from_esod, default: true
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
