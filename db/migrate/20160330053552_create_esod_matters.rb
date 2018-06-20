class CreateEsodMatters < ActiveRecord::Migration
  def change
    create_table :esod_matters do |t|
      t.integer :nrid, limit: 8
      t.string :znak, index: true
      t.string :znak_sprawy_grupujacej
      t.string :symbol_jrwa
      t.string :tytul, index: true
      t.date :termin_realizacji
      t.integer :identyfikator_kategorii_sprawy, index: true
      t.string :adnotacja
      t.integer :identyfikator_stanowiska_referenta, index: true
      t.boolean :czy_otwarta, default: true
      t.datetime :data_utworzenia
      t.integer :identyfikator_osoby_tworzacej
      t.datetime :data_modyfikacji
      t.integer :identyfikator_osoby_modyfikujacej
      t.boolean :initialized_from_esod, default: false
      t.integer :netpar_user
      t.references :exam, index: true, foreign_key: true
      t.references :examination, index: true, foreign_key: true
      t.references :certificate, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
