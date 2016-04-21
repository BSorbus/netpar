class CreateEsodContractors < ActiveRecord::Migration
  def change
    create_table :esod_contractors do |t|
      t.integer :nrid, index: true
      t.string :imie
      t.string :nazwisko
      t.string :nazwa
      t.string :drugie_imie
      t.string :tytul
      t.string :nip
      t.string :pesel
      t.integer :rodzaj
      t.integer :id_zalozyl
      t.integer :id_aktualizowal
      t.date :data_zalozenia
      t.date :data_aktualizacji
      t.boolean :initialized_from_esod, default: true
      t.integer :netpar_user

      t.timestamps null: false
    end
  end
end
