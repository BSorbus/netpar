class CreateEsodAddresses < ActiveRecord::Migration
  def change
    create_table :esod_addresses do |t|
      t.integer :nrid, limit: 8
      t.string :miasto
      t.string :kod_pocztowy
      t.string :ulica
      t.string :numer_lokalu
      t.string :numer_budynku
      t.string :skrytka_epuap
      t.string :panstwo
      t.string :email
      t.string :typ
      t.datetime :data_utworzenia
      t.integer :identyfikator_osoby_tworzacej
      t.datetime :data_modyfikacji
      t.integer :identyfikator_osoby_modyfikujacej
      t.boolean :initialized_from_esod, default: false
      t.integer :netpar_user
      t.references :customer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
