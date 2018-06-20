class CreateTerytTercCodes < ActiveRecord::Migration
  def change
    create_table :teryt_terc_codes do |t|
      t.string :woj, limit: 2
      t.string :pow, limit: 2
      t.string :gmi, limit: 2
      t.string :rodz, limit: 1
      t.string :nazwa, limit: 36
      t.string :nazdod, limit: 50
      t.date :stan_na

      t.timestamps null: false
    end
  end
end
