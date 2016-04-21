class CreateEsodAddresses < ActiveRecord::Migration
  def change
    create_table :esod_addresses do |t|
      t.integer :nrid, index: true
      t.string :miasto
      t.string :kod_pocztowy
      t.string :ulica
      t.string :numer_lokalu
      t.string :numer_budynku
      t.string :skrytka_epuap
      t.string :panstwo
      t.string :email
      t.string :typ
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
