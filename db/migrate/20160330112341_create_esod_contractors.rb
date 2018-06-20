class CreateEsodContractors < ActiveRecord::Migration
  def change
    create_table :esod_contractors do |t|
      t.integer :nrid, limit: 8
      t.string :imie
      t.string :nazwisko
      t.string :nazwa
      t.string :drugie_imie
      t.string :tytul
      t.string :nip
      t.string :pesel
      t.integer :rodzaj
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
