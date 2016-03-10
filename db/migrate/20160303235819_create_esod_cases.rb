class CreateEsodCases < ActiveRecord::Migration
  def change
    create_table :esod_cases do |t|
      t.integer :nrid
      t.string :znak
      t.string :znak_sprawy_grupujacej
      t.string :symbol_jrwa
      t.string :tytul
      t.date :termin_realizacji
      t.integer :identyfikator_kategorii_sprawy
      t.string :adnotacja
      t.integer :identyfikator_stanowiska_referenta
      #t.boolean :czy_otwarta
      t.datetime :esod_created_at
      t.datetime :esod_updated_et

      t.timestamps null: false
    end
    add_index :esod_cases, [:nrid],       unique: true
    add_index :esod_cases, [:znak],       unique: true
  end
end
