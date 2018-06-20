class CreateTerytUlicCodes < ActiveRecord::Migration
  def change
    create_table :teryt_ulic_codes do |t|
      t.string :woj, limit: 2
      t.string :pow, limit: 2
      t.string :gmi, limit: 2
      t.string :rodz_gmi, limit: 1
      t.string :sym, limit: 7
      t.string :sym_ul, limit: 5
      t.string :cecha, limit: 5
      t.string :nazwa_1, limit: 100
      t.string :nazwa_2, limit: 100
      t.date :stan_na

      t.timestamps null: false
    end
  end
end
