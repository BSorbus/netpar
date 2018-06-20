class CreateTerytPnaCodes < ActiveRecord::Migration
  def change
    create_table :teryt_pna_codes do |t|
      t.string :woj, limit: 2
      t.string :woj_nazwa, limit: 36
      t.string :pow, limit: 2
      t.string :pow_nazwa, limit: 36
      t.string :gmi, limit: 2
      t.string :gmi_nazwa, limit: 36
      t.string :nazdod, limit: 50
      t.string :rodz_gmi, limit: 1
      t.string :rodz_gmi_nazwa
      t.string :rm, limit: 2
      t.string :rm_nazwa, limit: 56
      t.string :sym, limit: 7
      t.string :sym_nazwa, limit: 56
      t.string :sympod, limit: 7
      t.string :sympod_nazwa
      t.string :sym_ul, limit: 5
      t.string :mie_nazwa, limit: 115 # 56 (56)
      t.string :uli_nazwa
      t.string :cecha, limit: 5
      t.string :nazwa_1, limit: 100
      t.string :nazwa_2, limit: 100
      t.date :stan_na
      t.string :teryt, null: false  
      t.string :pna, limit: 6
      t.string :numery
      t.string :pna_teryt

      t.timestamps null: false
    end
    add_index :teryt_pna_codes, :woj
    add_index :teryt_pna_codes, :woj_nazwa
    add_index :teryt_pna_codes, :pow
    add_index :teryt_pna_codes, :pow_nazwa
    add_index :teryt_pna_codes, :gmi
    add_index :teryt_pna_codes, :gmi_nazwa
    add_index :teryt_pna_codes, :sym
    add_index :teryt_pna_codes, :sym_nazwa
    add_index :teryt_pna_codes, :sympod
    add_index :teryt_pna_codes, :sympod_nazwa
    add_index :teryt_pna_codes, :mie_nazwa
    add_index :teryt_pna_codes, :uli_nazwa
    add_index :teryt_pna_codes, :pna
    add_index :teryt_pna_codes, :pna_teryt #, unique: true
    add_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :pna]

  end
end
