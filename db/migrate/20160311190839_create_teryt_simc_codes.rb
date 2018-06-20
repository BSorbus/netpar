class CreateTerytSimcCodes < ActiveRecord::Migration
  def change
    create_table :teryt_simc_codes do |t|
      t.string :woj, limit: 2
      t.string :pow, limit: 2
      t.string :gmi, limit: 2
      t.string :rodz_gmi, limit: 1
      t.string :rm, limit: 2
      t.string :mz, limit: 1
      t.string :nazwa, limit: 56
      t.string :sym, limit: 7
      t.string :sympod, limit: 7
      t.date :stan_na

      t.timestamps null: false
    end
  end
end
